#!/usr/bin/bash

echo '#!/bin/bash' > tmp_batch_userdata_$$
#env_id="nonprod"
#source ./Batch/var/read_variables.sh $env_id

# Launch config/app server does not have permission to do this
##Update DNS Name for SMB Server - todo
#echo 'aws route53 change-resource-record-sets --hosted-zone-id '$CRMS_DNS_ZONE_ID' --change-batch ''
# { "Changes":
#        [
#
#                {       "Action": "UPSERT",
#                        "ResourceRecordSet": {
#                                "Name": "'$BATCH_DNS.$CRMS_DNS_ZONE_NAME'",
#                                "Type": "CNAME",
#                                "TTL": 3600,
#                                "ResourceRecords": [
#                                        { "Value": "$(hostname -i)"}
#                                ]
#                        }
#                }
#        ]
#}
#' >> tmp_batch_userdata_$$

#Apply patch in background when autoscaling kicks in
echo "echo 'curl https://hip.ext.national.com.au/hip_upgrade.sh | bash -s -- -a latest' > /tmp/patch-me.sh" >> tmp_batch_userdata_$$
echo "nohup sudo /usr/bin/bash /tmp/patch-me.sh &" >> tmp_batch_userdata_$$

aws cloudformation deploy \
        --template-file Batch/template/Linux_Batch_Autoscaling.yml \
        --stack-name GEMINI-WEB-$Name \
        --parameter-overrides \
                  "IAMInstanceProfile=$IAMInstanceProfile" \
                  "ImageId=$ImageId" \
                  "InstanceType=$InstanceType" \
                  "KeyPairName=$KeyPairName" \
                  "RemoteAccessCIDR=$RemoteAccessCIDR" \
                  "Subnets=$Subnets" \
                  "VpcId=$VpcId" \
                  "ApplicationID=$ApplicationID" \
                  "Owner=$Owner" \
                  "UserData1=$(cat tmp_batch_userdata_$$|openssl base64 -A)" \
        --tags \
                  "CostCentre=$CostCentre" \
                  "Name=GeminiWeb-$Name" \
                  "Environment=$Environment" \
                  "AppCategory=$AppCategory" \
                  "SupportGroup=$SupportGroup" \
                  "PowerMgt=$PowerMgt"
        #         "IAMInstanceProfile=$IAM_PROFILE_INST" \
        #         "ImageId=`aws ssm get-parameter --name "/gemini_archive_web/ami_image-Deploy" --with-decryption --region "ap-southeast-2" | grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'"` \
        #         "InstanceType=$INSTANCE_TYPE_BATCH" \
        #         "KeyPairName=$KEYPAIR_NAME" \
        #         "RemoteAccessCIDR=$SSHACCESSCIDR" \
        #         "Subnets=$SUBNETID1,$SUBNETID2,$SUBNETID3" \
        #         "VpcId=$VPCID" \
        #         "ApplicationID=$T_ApplicationID" \
        #         "Owner=$Owner" \
        #         "UserData1=$(cat tmp_batch_userdata_$$|openssl base64 -A)" \
        # --tags \
        #         "CostCentre=$T_CostCentre" \
        #         "Name=GeminiWeb-$T_Environment" \
        #         "Environment=$T_Environment" \
        #         "AppCategory=$T_AppCategory" \
        #         "SupportGroup=$T_SupportGroup" \
        #         "PowerMgt=$T_EC2_PowerMgt"
cat tmp_batch_userdata_$$
rm tmp_batch_userdata_$$

#restart all EC2 by killing them.
#asg_group_name=$(aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$T_Environment| jq -r '.StackResources[]|select (.LogicalResourceId=="AutoScalingGroup").PhysicalResourceId'|sed 's/ /,/g')
#instances=$(aws autoscaling describe-auto-scaling-instances | jq -r '.AutoScalingInstances[]|select (.AutoScalingGroupName=="'$asg_group_name'").InstanceId'|paste -sd " " -)
# aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --instance-id  \
#                 $(aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-names  \
#                         $(aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$Name \
#                         |jq -r '.StackResources[]|select (.ResourceType=="AWS::AutoScaling::AutoScalingGroup").PhysicalResourceId')  \
#                 |jq -r '.AutoScalingGroups[0].Instances[].InstanceId') \
#         |jq -r '.Reservations[].Instances[].InstanceId')

