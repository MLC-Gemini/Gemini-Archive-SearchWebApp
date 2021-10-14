#!/usr/bin/bash

cleanup() {
	rm -f tmp_batch_userdata_$$
	rm -f tmp_launch_asg_$$.sh
	rm -f encrypted_device_mapping_$$.json
	aws ec2 terminate-instances --instance-ids $instance_id
	#rm -rf $Git_Working_Folder        
}
trap cleanup EXIT

#env_id="nonprod"
env_id=$1
source ./Batch/var/read_variables.sh $env_id

######################################
echo "1. Bake 100% ready ami"
#The ami should have all necessary credential built in as "ApplicationServerProfile" does not have permission to access SSM etc.

ami_id=`aws ssm get-parameters --name $AWS_PAR_BATCH_IMAGE --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
kms_ec2_keyid=`aws ssm get-parameters --name $GEM_KMS --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
echo $ami_id
echo $kms_ec2_keyid

if [[ $kms_ec2_keyid == 'null' ]]; then
# export the varibale needed for kms josn template files.
  export OWNER_ACCOUNT="${OWNER_ACCOUNT}"
  export KMS_ROLE_DELETE_ALLOW="${KMS_ROLE_DELETE_ALLOW}"
  export IAM_PROFILE_PROV="${IAM_PROFILE_PROV}"
  export GEMINI_PROV_ROLE_ID="${GEMINI_PROV_ROLE_ID}"
  export IAM_PROFILE_INST="${IAM_PROFILE_INST}"

  envsubst < Batch/template/kms_policy_ami_template.json > kms_policy_ami_$$.json
  kms_ec2_keyid=$(aws kms create-key --policy file://kms_policy_ami_$$.json|jq -r '.KeyMetadata.KeyId')
	#CAST requirement to enable key rotation
  aws kms enable-key-rotation --key-id $(echo $kms_ec2_keyid|sed 's/^.*\///')
  aws kms create-alias --alias-name alias/$GEM_KMS --target-key-id $(echo $kms_ec2_keyid|sed 's/^.*\///')
  aws ssm put-parameter --name $GEM_KMS --value $kms_ec2_keyid --type "SecureString" --region "ap-southeast-2" --overwrite
fi
aws ec2 describe-images --image-id $ami_id|jq -r '.Images[].BlockDeviceMappings|del(.[].Ebs.SnapshotId)|.[].Ebs.Encrypted=true|.[].Ebs.KmsKeyId="'$kms_ec2_keyid'"' > encrypted_device_mapping_$$.json

instance_id=`\
aws ec2 run-instances \
    --block-device-mappings file://encrypted_device_mapping_$$.json \
    --subnet-id $SUBNETID1 \
    --image-id $ami_id \
    --instance-type $INSTANCE_TYPE_BATCH \
    --iam-instance-profile Name=$IAM_PROFILE_PROV \
    | jq ".Instances[0]|.InstanceId"|sed "s/\"//g"`

aws ec2 create-tags --resources $instance_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id Key=TechnicalService,Value=$TechnicalService Key=Owner,Value=$Owner Key=Name,Value=$Name Key=Account,Value=$Account

aws ec2 wait instance-status-ok --instance-ids $instance_id

echo $instance_id
#Give enough time to complete user-data section, if this was the cause of
#problem(smb part of code was not executedss)
#sleep 60

ts=`date +%Y-%m-%d-%H-%M-%S`
image_id=$(aws ec2 create-image --name Gemini-web-deploy-$ts --instance-id $instance_id|jq -r ".ImageId")
aws ec2 create-tags --resources $image_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=Deploy-$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id

echo "- wait for image to be created"
aws ec2 wait image-available --image-ids $image_id
echo "- Wait for image to be available"
while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
do
        sleep 30
done

echo "- Register 100% baked image"
#./aws/aws_put_parameter.sh Deploy-$AWS_PAR_BATCH_IMAGE $image_id
aws ssm put-parameter --name $AWS_PAR_BATCH_IMAGE-deploy --value $image_id --type "SecureString" --region "ap-southeast-2" --overwrite

# ######################################
echo "2. Start Autoscling group using 100% backed ami"
  ImageId=`aws ssm get-parameter --name $AWS_PAR_BATCH_IMAGE-deploy --with-decryption --region "ap-southeast-2" | grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`
  echo $ImageId

  export ImageId="${ImageId}"
  export IAMInstanceProfile="${IAM_PROFILE_INST}"
  export InstanceType="${INSTANCE_TYPE_BATCH}"
  export KeyPairName="${KEYPAIR_NAME}"
  export RemoteAccessCIDR="${SSHACCESSCIDR}"
  export Subnet1="${SUBNETID1}"
  export Subnet2="${SUBNETID2}"
  export Subnet3="${SUBNETID3}"
  export VpcId="${VPCID}"
  export ApplicationID="${T_ApplicationID}"
  export Owner="${Owner}"
  export CostCentre="${T_CostCentre}"
  export Name="${T_Environment}"
  export Environment="${T_Environment}"
  export AppCategory="${T_AppCategory}"
  export SupportGroup="${T_SupportGroup}"
  export PowerMgt="${T_EC2_PowerMgt}"
  export OWNER_ACCOUNT="${OWNER_ACCOUNT}"
  export ALB_SSL_CERT_NAME="${ALB_SSL_CERT_NAME}"

envsubst < Batch/template/Linux_Batch_Autoscaling.sh > tmp_launch_asg_$$.sh
bash tmp_launch_asg_$$.sh

# ######################################
# echo "3. Set DNS entry"
 lb_arn=$(aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$T_Environment \
 	|jq -r '.StackResources[]|select (.LogicalResourceId=="LoadBalancer").PhysicalResourceId')
 lb_dns=$(aws elbv2 describe-load-balancers --load-balancer-arns $lb_arn |jq -r '.LoadBalancers[0].DNSName')
#  echo $env_id
#  echo $GEMINIWEB_DNS
#  echo $GEMINI_DNS_ZONE_NAME
#  echo $lb_dns
 ./Batch/aws_set_dns.sh $env_id $GEMINIWEB_DNS.$GEMINI_DNS_ZONE_NAME $lb_dns

# ##Added below code as CAST requirement to verify the resource is up and running
 while [[   $(aws ec2 describe-instances --instance-id  \
                 $(aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-names  \
                         $(aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$T_Environment \
                         |jq -r '.StackResources[]|select (.ResourceType=="AWS::AutoScaling::AutoScalingGroup").PhysicalResourceId')  \
                 |jq -r '.AutoScalingGroups[0].Instances[].InstanceId') \
         | jq -r '.Reservations[].Instances[].State.Name') != 'running' ]]
 do
 	echo "Wait for ec2 instance ready......"
 	sleep 60
 done
