
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
ec2instanceSG=$(aws ssm get-parameter  --name "/gemini_archive_web/ec2instanceSG" --query "Parameter.Value" --output text)

sed -e "s/oldAMI/$ami_id/g;s/oldSG/$ec2instanceSG/g" template/dev-rhel8.json_template > dev-rhel8.json

echo $ami_id

aws cloudformation deploy --region ap-southeast-2 --stack-name GeminiPreDeployJune \
    --template-file cloudformation/ec2-launchtemplate-key.yaml \
    --capabilities CAPABILITY_NAMED_IAM --parameter-overrides file://dev-rhel8.json

instance_id=`aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId[]" \
    --filters "Name=tag-key,Values=aws:cloudformation:stack-name" "Name=tag-value,Values=GeminiPreDeployJune" --output=text`

echo "- Wait for instance status OK"
aws ec2 wait instance-status-ok --instance-ids $instance_id

echo $instance_id

ts=`date +%Y-%m-%d-%H-%M-%S`
image_id=$(aws ec2 create-image --name Gemini-web-deploy-june-$ts --instance-id $instance_id|jq -r ".ImageId")
aws ec2 create-tags --resources $image_id --tags Key=PatchCycle,Value=$T_PatchCycle Key=Environment,Value=$T_Environment Key=T_CostCentre,Value=$T_CostCentre Key=DataClassification,Value=$T_DataClassification Key=Owner,Value=$T_Owner Key=PowerMgt,Value=$T_PowerMgt Key=Name,Value=$T_Name Key=ApplicationID,Value=$T_ApplicationID Key=OUName,Value=$T_OUName Key=map-migrated,Value=$T_MapMigrated

echo "- wait for image to be created"
aws ec2 wait image-available --image-ids $image_id
echo "- Wait for image to be available"
while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
do
        sleep 30
done

echo "2. Register 100% baked image"
#./aws/aws_put_parameter.sh Deploy-$AWS_PAR_BATCH_IMAGE $image_id
aws ssm put-parameter --name $AWS_PAR_BATCH_IMAGE-deploy --value $image_id --type "SecureString" --region "ap-southeast-2" --overwrite

echo "3. Deploy the stack with the latest baked image"
ImageId=`aws ssm get-parameter --name $AWS_PAR_BATCH_IMAGE-deploy --with-decryption --region "ap-southeast-2" | grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`
echo $ImageId

ec2instanceSG=$(aws ssm get-parameter  --name "/gemini_archive_web/ec2instanceSG" --query "Parameter.Value" --output text)

sed -e "s/oldAMI/$ImageId/g;s/oldSG/$ec2instanceSG/g" template/dev-rhel8.json_template > dev-rhel8.json

aws cloudformation deploy --region ap-southeast-2 --stack-name GEMINI-WEB-June-$env_id-Stack \
    --template-file cloudformation/ec2-autoscaling-cert.yaml \
    --capabilities CAPABILITY_NAMED_IAM --parameter-overrides file://dev-rhel8.json
	
#echo "4. Create Cloud watch"
#_pipeline/create_cloud_watch_ec2.sh $env_id
