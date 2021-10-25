#!/usr/bin/bash

echo '#!/bin/bash' > tmp_batch_userdata_$$
echo "echo 'curl https://hip.ext.national.com.au/hip_upgrade.sh | bash -s -- -a latest' > /tmp/patch-me.sh" >> tmp_batch_userdata_$$
echo "nohup sudo /usr/bin/bash /tmp/patch-me.sh &" >> tmp_batch_userdata_$$

aws cloudformation deploy \
        --template-file Batch/template/Linux_Batch_Autoscaling.yml \
        --stack-name GEMINI-WEB-$Name-Stack \
        --parameter-overrides \
                  "IAMInstanceProfile=$IAMInstanceProfile" \
                  "ImageId=$ImageId" \
                  "InstanceType=$InstanceType" \
                  "KeyPairName=$KeyPairName" \
                  "RemoteAccessCIDR=$RemoteAccessCIDR" \
                  Subnets="$Subnet1,$Subnet2,$Subnet3" \
                  "VpcId=$VpcId" \
                  "ApplicationID=$ApplicationID" \
                  "Owner=$Owner" \
                  "UserData1=$(cat tmp_batch_userdata_$$|openssl base64 -A)" \
                  "OwnerAccount=$OWNER_ACCOUNT" \
                  "AlbSSLCertName=$ALB_SSL_CERT_NAME" \
        --tags \
                  "CostCentre=$CostCentre" \
                  "Name=GeminiWeb-$Name" \
                  "Environment=$Environment" \
                  "AppCategory=$AppCategory" \
                  "SupportGroup=$SupportGroup" \
                  "PowerMgt=$PowerMgt"
cat tmp_batch_userdata_$$
rm tmp_batch_userdata_$$

#restart all EC2 by killing them.
 asg_group_name=$(aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$Name| jq -r '.StackResources[]|select (.LogicalResourceId=="AutoScalingGroup").PhysicalResourceId'|sed 's/ /,/g')
 instances=$(aws autoscaling describe-auto-scaling-instances | jq -r '.AutoScalingInstances[]|select (.AutoScalingGroupName=="'$asg_group_name'").InstanceId'|paste -sd " " -)
 aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --instance-id  \
                 $(aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-names  \
                         $(aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$Name \
                         |jq -r '.StackResources[]|select (.ResourceType=="AWS::AutoScaling::AutoScalingGroup").PhysicalResourceId')  \
                 |jq -r '.AutoScalingGroups[0].Instances[].InstanceId') \
         |jq -r '.Reservations[].Instances[].InstanceId')

