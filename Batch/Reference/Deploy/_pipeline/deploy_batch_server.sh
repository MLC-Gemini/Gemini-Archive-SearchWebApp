#!/usr/bin/bash

#./_pipeline/deploy_batch_server.sh CRMSD02,CRMSD03,CRMSD04
#To append an environment:	./_pipeline/deploy_batch_server.sh CRMSD05
#be aware: CRMSD01 is pointing to provisioning VPC, it should not be part of this group
cleanup() {
	rm -f tmp_batch_userdata_$$
	rm -f tmp_launch_asg_$$.sh
	rm -f encrypted_device_mapping_$$.json
	aws ec2 terminate-instances --instance-ids $instance_id
	rm -rf $Git_Working_Folder        
}
trap cleanup EXIT

IFS=','; read -ra dbnames <<< "$1"; export dbname=${dbnames[0]}; export dbnames; unset IFS

#Need deploy from a particular version
source aws/checkout_stable_release.sh $dbname

./_pipeline/_prepare_environment.sh $dbname
dbname_lowercase=${dbname,,}

#Create KMS_EFS if not exists
kms_efs_arn=$(./aws/aws_get_parameter.sh $KMS_EFS)
if [[ $kms_efs_arn == '' || $kms_efs_arn == 'null' ]]; then
        envsubst < aws/CRMS_CFM/template/kms_policy_efs_template.json > kms_policy_efs_$$.json
        kms_efs_arn=$(aws kms create-key --policy file://kms_policy_efs_$$.json|jq -r '.KeyMetadata.Arn')
        #CAST requirement to enable key rotation
        aws kms enable-key-rotation --key-id $(echo $kms_efs_arn|sed 's/^.*\///')
        aws kms create-alias --alias-name alias/$KMS_EFS --target-key-id $(echo $kms_efs_arn|sed 's/^.*\///')
        ./aws/aws_put_parameter.sh "$KMS_EFS" "$kms_efs_arn"
fi

######################################
echo "1. Create/Replace EFS stack"
aws cloudformation deploy \
	--template-file aws/CRMS_CFM/batch_efs.yml \
    	--stack-name CRMS-EFS-$T_Environment \
    	--parameter-overrides \
		"KMSKeyAliasName=$kms_efs_arn" \
  		"Subnet1ID=$SUBNETID1" \
  		"Subnet2ID=$SUBNETID2" \
  		"Subnet3ID=$SUBNETID3" \
  		"VpcCIDR=$SSHACCESSCIDR" \
  		"VpcId=$VPCID" \
	--tags \
    		"CostCentre=$T_CostCentre" \
    		"ApplicationID=$T_ApplicationID" \
    		"Environment=$T_Environment" \
    		"AppCategory=$T_AppCategory" \
    		"SupportGroup=$T_SupportGroup" \
    	        "PowerMgt=$T_EC2_PowerMgt" 

efsid=$(aws cloudformation describe-stack-resources --stack-name CRMS-EFS-$T_Environment|jq -r '.StackResources[]|select (.LogicalResourceId=="BATCHFileSystem").PhysicalResourceId')
aws efs put-file-system-policy --file-system-id $efsid --policy '
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "efs-encrypt-in-transit",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "*",
            "Resource": "'arn:aws:elasticfilesystem:$REGION:$OWNER_ACCOUNT:file-system/$efsid'",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
            "Sid": "efs-allow-access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
'
######################################
echo "2. Prepare userdata"

#Prepare linux server to host multiple environments
support_topic_arn=$(aws sns create-topic --name SNS_Support_$T_Environment | jq -r '.TopicArn')
IFS=',';read -ra email_address <<< "$CRMS_SUPPORT_EMAIL"
for i in "${email_address[@]}"
do
	aws sns subscribe --topic-arn "$support_topic_arn" --protocol email --notification-endpoint "$i"
done

#Config server
echo '#!/bin/bash' > tmp_batch_userdata_$$
echo "sed \"s/dbname/$dbname_lowercase/\" /tmp/Cloudwatch_EC2_config.json > /tmp/Cloudwatch_EC2_config_$dbname.json" >> tmp_batch_userdata_$$
echo "mv -f /tmp/Cloudwatch_EC2_config_$dbname.json /tmp/Cloudwatch_EC2_config.json" >> tmp_batch_userdata_$$
echo "/tmp/config_batch_server.sh $efsid $SSM_PUBKEY $support_topic_arn $SSM_SERVER_HOST_KEY $TWR_SCPKEY $TWR_SSM_KEY | tee -a /tmp/userdata.log " >> tmp_batch_userdata_$$

#Config multiple database environments
for i in "${dbnames[@]}"
do
        source ./env_def/read_variables.sh $i
	./aws/aws_put_parameter.sh PWD-$CRMS_DBNAME $CRMS_PWD
	echo "/tmp/config_batch_env.sh $CRMS_DBNAME $CRMS_UID $CRMS_RDS_DNS.$CRMS_DNS_ZONE_NAME $RDS_SSL_PORT  | tee -a /tmp/userdata.log " >> tmp_batch_userdata_$$
done

#Config AD Integration
echo "chmod 755 /tmp/config_batch_ad.sh " >> tmp_batch_userdata_$$
echo "/tmp/config_batch_ad.sh $BATCH_AD_PARENT_DOMAIN $BATCH_AD_CHILD_DOMAIN | tee -a /tmp/userdata.log" >> tmp_batch_userdata_$$

#Config SMB if required
if [ ${SMB_UID+x} ]; then
	./aws/aws_put_parameter.sh PWD-$dbname-$SMB_UID $CRMS_PWD
	echo "/usr/bin/bash /tmp/config_batch_smb.sh $SMB_UID PWD-$dbname-$SMB_UID  | tee -a /tmp/userdata.log" >> tmp_batch_userdata_$$
fi

#Start control-m agent as service for this environment etc
kms_ec2_keyid=$(./aws/aws_get_parameter.sh $KMS_EC2)
echo "/tmp/config_batch_final.sh $CTM_AGENT_SHORT $CTM_SERVER_NAME $CTM_AGENT_TO_SERVER_PORT $CTM_SERVER_TO_AGENT_PORT $KMS_EC2  | tee -a /tmp/userdata.log" >> tmp_batch_userdata_$$

#Add EFS to S3 sync
echo "crontab << EOF
01 10 * * * export http_proxy=http://forwardproxy:3128;export https_proxy=http://forwardproxy:3128;export no_proxy=localhost,169.254.169.254,hip.ext.national.com.au,github.aus.thenational.com,artifactory.ext.national.com.au;/usr/local/bin/aws s3 sync /extract s3://crms${T_Environment,,}-crms-s3elb${TEST_ENV,,} --sse aws:kms --sse-kms-key-id $kms_ec2_keyid > /tmp/s3_sync.log
00 18 8-14 * 7 echo \"START patching \" >> /tmp/weekly-patching.log ; curl https://hip.ext.national.com.au/hip_upgrade.sh | bash -s -- -a latest ; echo \"FINISH patching\" >> /tmp/weekly-patching.log;
EOF  | tee -a /tmp/userdata.log" >> tmp_batch_userdata_$$

#echo "bash /tmp/defer_to_user_data.sh; rm /tmp/defer_to_user_data.sh" >> tmp_batch_userdata_$$

######################################
echo "3. Bake 100% ready ami"
#The ami should have all necessary credential built in as "ApplicationServerProfile" does not have permission to access SSM etc.
ami_id=$(./aws/aws_get_parameter.sh $AWS_PAR_BATCH_IMAGE)
kms_ec2_keyid=$(./aws/aws_get_parameter.sh $KMS_EC2)
if [[ $kms_ec2_keyid == 'null' ]]; then
        envsubst < aws/CRMS_CFM/template/kms_policy_ami_template.json > kms_policy_ami_$$.json
        kms_ec2_keyid=$(aws kms create-key --policy file://kms_policy_ami_$$.json|jq -r '.KeyMetadata.KeyId')
        #CAST requirement to enable key rotation
        aws kms enable-key-rotation --key-id $(echo $kms_ec2_keyid|sed 's/^.*\///')
        ./aws/aws_put_parameter.sh $KMS_EC2 $kms_ec2_keyid
fi
aws ec2 describe-images --image-id $ami_id|jq -r '.Images[].BlockDeviceMappings|del(.[].Ebs.SnapshotId)|.[].Ebs.Encrypted=true|.[].Ebs.KmsKeyId="'$kms_ec2_keyid'"' > encrypted_device_mapping_$$.json


instance_id=$( \
aws ec2 run-instances \
    --block-device-mappings file://encrypted_device_mapping_$$.json \
    --subnet-id $SUBNETID1 \
    --image-id $ami_id \
    --instance-type $INSTANCE_TYPE_BATCH \
    --iam-instance-profile Name=$IAM_PROFILE_PROV \
    --user-data file://tmp_batch_userdata_$$ \
    --tag-specifications \
        "ResourceType=instance,
        Tags=[
                {Key=CostCentre,Value=$T_CostCentre},
                {Key=ApplicationID,Value=$T_ApplicationID},
                {Key=Environment,Value=$T_Environment},
                {Key=AppCategory,Value=$T_AppCategory},
                {Key=SupportGroup,Value=$T_SupportGroup},
                {Key=PowerMgt,Value=$T_EC2_PowerMgt},
                {Key=BackupOptOut,Value=$T_BackupOptOut},
                {Key=HIPImage,Value=$ami_id},
                {Key=TechnicalService,Value=CRMS},
                {Key=Owner,Value=CRMS},
                {Key=Account,Value=CRMS},
                {Key=Name,Value=Batch-bake-deploy}
        ]" | jq -r ".Instances[0]|.InstanceId")
aws ec2 wait instance-status-ok --instance-ids $instance_id

#Give enough time to complete user-data section, if this was the cause of
#problem(smb part of code was not executedss)
sleep 300

ts=`date +%Y-%m-%d-%H-%M-%S`
image_id=$(aws ec2 create-image --name Batch-deploy-$ts --instance-id $instance_id|jq -r ".ImageId")
aws ec2 create-tags --resources $image_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=Batch-deploy-$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id

echo "- wait for image to be created"
aws ec2 wait image-available --image-ids $image_id
echo "- Wait for image to be available"
while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
do
        sleep 30
done


echo "- Register 100% baked image"
./aws/aws_put_parameter.sh Deploy-$AWS_PAR_BATCH_IMAGE $image_id



######################################
echo "4. Create S3 Bucket for EC2 Logging for CAST"
./_pipeline/create_s3_elb.sh $dbname

######################################
echo "5. Start Autoscling group using 100% backed ami"
export hip_topic_arn=$(aws sns create-topic --name SNS_Batch_$T_Environment | jq -r '.TopicArn')

export efsid
envsubst < aws/CRMS_CFM/Linux_Batch_Autoscaling.sh > tmp_launch_asg_$$.sh
bash tmp_launch_asg_$$.sh


echo "6. Set DNS entry"
lb_arn=$(aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV \
	|jq -r '.StackResources[]|select (.LogicalResourceId=="LoadBalancer").PhysicalResourceId')
lb_dns=$(aws elbv2 describe-load-balancers --load-balancer-arns $lb_arn |jq -r '.LoadBalancers[0].DNSName')
./aws/aws_set_dns.sh $dbname $BATCH_DNS.$CRMS_DNS_ZONE_NAME $lb_dns

##Added below code as CAST requirement to verify the resource is up and running
while [[   $(aws ec2 describe-instances --instance-id  \
                $(aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-names  \
                        $(aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV \
                        |jq -r '.StackResources[]|select (.ResourceType=="AWS::AutoScaling::AutoScalingGroup").PhysicalResourceId')  \
                |jq -r '.AutoScalingGroups[0].Instances[].InstanceId') \
        | jq -r '.Reservations[].Instances[].State.Name') != 'running' ]]
do
	echo "Wait for ec2 instance ready......"
	sleep 60
done

echo "7. Create Cloud watch"
_pipeline/create_cloud_watch_ec2.sh $dbname
