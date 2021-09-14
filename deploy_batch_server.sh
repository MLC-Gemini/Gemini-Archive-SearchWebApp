#!/usr/bin/bash

#./_pipeline/deploy_batch_server.sh
#To append an environment:	./_pipeline/deploy_batch_server.sh CRMSD05
#be aware: CRMSD01 is pointing to provisioning VPC, it should not be part of this group
# cleanup() {
# 	rm -f tmp_batch_userdata_$$
# 	rm -f tmp_launch_asg_$$.sh
# 	rm -f encrypted_device_mapping_$$.json
# 	aws ec2 terminate-instances --instance-ids $instance_id
# 	rm -rf $Git_Working_Folder        
# }
# trap cleanup EXIT

# Bake AMI require variables

# #Git_Working_Folder=""
# env_id="nonprod"

# # Tooling VPC
# #VPCID="vpc-0a78b82ba9196ca94" 
# # Private VPC
# VPCID="vpc-0ecf6cd42dacf1a57"
# # tooling subnet a
# #SUBNETID1="subnet-01470aa7fd78e4888" 
# # private subnet 2a
# SUBNETID1="subnet-01132417d1533351a" 

# SSHACCESSCIDR="10.0.0.0/8"
# #GEM_KMS="KMS_EC2_DEFAULT"
# GEM_KMS="gemini_archive_web_ec2"
# BATCH_SERVER_SIZE=50
# INSTANCE_TYPE_BATCH="t3.small"
# IAM_PROFILE_PROV="GeminiProvisioningInstanceProfile"

# # Aws Tags
# T_CostCentre="V_Gemini" 
# #T_ApplicationID="M4456"
# T_ApplicationID="ML0095"
# T_Environment="nonprod"
# T_AppCategory="B"
# T_SupportGroup="WorkManagementProductionSupport"
# T_Name="Gemini_web"
# #T_EC2_PowerMgt="EXTSW,0,1"
# T_EC2_PowerMgt="EXTSW"
# T_BackupOptOut="No"

# #Deploy Bake 
# TechnicalService="GeminiWeb"
# Owner="GeminiWeb"
# Account="GeminiWeb"
# Name="GeminiWeb-bake-deploy"

# AWS_PAR_BATCH_IMAGE="GeminiArchiveWeb"

env_id="nonprod"
source ./Batch/var/read_variables.sh $env_id

echo $TechnicalService
echo "Sandip"

######################################
echo "1. Bake 100% ready ami"
#The ami should have all necessary credential built in as "ApplicationServerProfile" does not have permission to access SSM etc.
#ami_id=$(./aws/aws_get_parameter.sh $AWS_PAR_BATCH_IMAGE)
#kms_ec2_keyid=$(./aws/aws_get_parameter.sh $KMS_EC2)
ami_id=`aws ssm get-parameters --name $AWS_PAR_BATCH_IMAGE --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
kms_ec2_keyid=`aws ssm get-parameters --name $GEM_KMS --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
echo $ami_id
# echo $kms_ec2_keyid

# if [[ $kms_ec2_keyid == 'null' ]]; then
# # export the varibale needed for kms josn files.
#   export OWNER_ACCOUNT='998622627571' KMS_ROLE_DELETE_ALLOW='AUR-Resource-AWS-gemininonprod-devops-appstack' IAM_PROFILE_PROV='GeminiProvisioningInstanceProfile' CRMS_PROV_ROLE_ID='GeminiProvisioningRole' IAM_PROFILE_INST='GeminiAppServerInstanceProfile'
#   MYVARS='$OWNER_ACCOUNT:$KMS_ROLE_DELETE_ALLOW:$IAM_PROFILE_PROV:$CRMS_PROV_ROLE_ID:$IAM_PROFILE_INST'

#   envsubst < Batch/template/kms_policy_ami_template.json > kms_policy_ami_$$.json
#   kms_ec2_keyid=$(aws kms create-key --policy file://kms_policy_ami_$$.json|jq -r '.KeyMetadata.KeyId')
# 	#CAST requirement to enable key rotation
#   aws kms enable-key-rotation --key-id $(echo $kms_ec2_keyid|sed 's/^.*\///')
#   aws kms create-alias --alias-name alias/$GEM_KMS --target-key-id $(echo $kms_ec2_keyid|sed 's/^.*\///')
#   aws ssm put-parameter --name $GEM_KMS --value $kms_ec2_keyid --type "SecureString" --region "ap-southeast-2" --overwrite
# fi
# aws ec2 describe-images --image-id $ami_id|jq -r '.Images[].BlockDeviceMappings|del(.[].Ebs.SnapshotId)|.[].Ebs.Encrypted=true|.[].Ebs.KmsKeyId="'$kms_ec2_keyid'"' > encrypted_device_mapping_$$.json

# instance_id=`\
# aws ec2 run-instances \
#     --block-device-mappings file://encrypted_device_mapping_$$.json \
#     --subnet-id $SUBNETID1 \
#     --image-id $ami_id \
#     --instance-type $INSTANCE_TYPE_BATCH \
#     --iam-instance-profile Name=$IAM_PROFILE_PROV \
#     | jq ".Instances[0]|.InstanceId"|sed "s/\"//g"`

# aws ec2 create-tags --resources $instance_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id Key=TechnicalService,Value=$TechnicalService Key=Owner,Value=$Owner Key=Name,Value=$Name Key=Account,Value=$Account

# aws ec2 wait instance-status-ok --instance-ids $instance_id

# echo $instance_id
# #Give enough time to complete user-data section, if this was the cause of
# #problem(smb part of code was not executedss)
# sleep 300

# ts=`date +%Y-%m-%d-%H-%M-%S`
# image_id=$(aws ec2 create-image --name Gemini-web-deploy-$ts --instance-id $instance_id|jq -r ".ImageId")
# aws ec2 create-tags --resources $image_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=Deploy-$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id

# echo "- wait for image to be created"
# aws ec2 wait image-available --image-ids $image_id
# echo "- Wait for image to be available"
# while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
# do
#         sleep 30
# done

# echo "- Register 100% baked image"
# #./aws/aws_put_parameter.sh Deploy-$AWS_PAR_BATCH_IMAGE $image_id
# aws ssm put-parameter --name Deploy-$AWS_PAR_BATCH_IMAGE --value $image_id --type "SecureString" --region "ap-southeast-2" --overwrite

# ######################################
# echo "2. Start Autoscling group using 100% backed ami"

# envsubst < Batch/template/Linux_Batch_Autoscaling.sh > tmp_launch_asg_$$.sh
# bash tmp_launch_asg_$$.sh

# ######################################
# echo "3. Set DNS entry"
# lb_arn=$(aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV \
# 	|jq -r '.StackResources[]|select (.LogicalResourceId=="LoadBalancer").PhysicalResourceId')
# lb_dns=$(aws elbv2 describe-load-balancers --load-balancer-arns $lb_arn |jq -r '.LoadBalancers[0].DNSName')
# ./aws/aws_set_dns.sh $dbname $BATCH_DNS.$CRMS_DNS_ZONE_NAME $lb_dns

# ##Added below code as CAST requirement to verify the resource is up and running
# while [[   $(aws ec2 describe-instances --instance-id  \
#                 $(aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-names  \
#                         $(aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV \
#                         |jq -r '.StackResources[]|select (.ResourceType=="AWS::AutoScaling::AutoScalingGroup").PhysicalResourceId')  \
#                 |jq -r '.AutoScalingGroups[0].Instances[].InstanceId') \
#         | jq -r '.Reservations[].Instances[].State.Name') != 'running' ]]
# do
# 	echo "Wait for ec2 instance ready......"
# 	sleep 60
# done
