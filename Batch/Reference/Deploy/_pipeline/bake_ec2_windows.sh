#./_pipeline/aws_bake_ec2_windows.sh CRMS-build-sh [CRMSD01]

cleanup() {
	echo "- Drop this instance"
	aws ssm delete-parameter --name "tmp_bake_$$"
	rm -f tmp_bake_$$
	rm -f tmp_bake_$$.pub
	sed -i "/tmp_bake_$$/d" ~ec2-user/.ssh/authorized_keys
	aws ec2 terminate-instances --instance-ids $instance_id
	rm -f tmp_robot_bake_prep_$$.ps1
	rm -f tmp_bake_robot_$env_id.pem
	aws ec2 delete-key-pair --key-name "tmpkey-CRMS-ROBOT-$env_id$$"
	aws ec2 wait instance-terminated --instance-ids $instance_id
	aws ec2 delete-security-group --group-id $crms_tmp_sec_group_id
	rm -f encrypted_device_mapping_$$.json
	rm -f /tmp/status_$$.txt
	rm -f /tmp/status_$$.log
	rm -rf $Git_Working_Folder
}
trap cleanup EXIT

env_id=CRMS-build
dbname=CRMSD01

env_id=$1
dbname=$2
echo "- Get environment variable"
if [[ $dbname != '' ]]; then
  source aws/checkout_stable_release.sh $dbname
  if [[ $? != 0 ]];then exit 1; fi
  #Make sure we don't accidentally overwrite test environment variables from build environment, use "SELECT"
  source ./env_def/read_variables.sh $env_id SELECT "VPCID,BUILD_STAGE,VPCID,SUBNETID1,SUBNETID2,SUBNETID3"
else
  source ./env_def/read_variables.sh $env_id
fi

artifact_folder=/tmp/robot_staging
echo "1. Download Windows Artifcat"
./Batch/get_robot_artifact.sh $env_id $artifact_folder
unix2dos -n ./powershell/robot_deploy.ps1 $artifact_folder/robot_deploy.ps1
unix2dos -n ./powershell/install_git.ps1 $artifact_folder/install_git.ps1
cp env_def/pCRMS_Crypt.dll $artifact_folder
cp env_def/pBlob.dll $artifact_folder
cp env_def/ProcessCopy.exe $artifact_folder
cp env_def/CRMS_Updater.exe $artifact_folder
cp env_def/CRMSServiceApp.exe $artifact_folder
cp powershell/install_git.ps1 $artifact_folder

#Create a temp key for baking process to access build box
ssh-keygen -b 2048 -t rsa -f tmp_bake_$$ -q -N "" <<< "y"
unix2dos tmp_bake_$$
./aws/aws_put_parameter.sh "tmp_bake_$$" "$(cat tmp_bake_$$)"
sed -i "/tmp_bake_$$/d" ~/.ssh/authorized_keys
cat tmp_bake_$$.pub | sed "s/$(hostname)/tmp_bake_$$/" | tee -a ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "2. UserData"
export BUILD_BOX_IP=$(hostname -i|awk '{print $1}')
export BUILD_BOX_ART_FOLDER=$artifact_folder
export BUILD_BOX_PID=$$

echo "<powershell>" 							>  tmp_robot_bake_prep_$$.ps1
echo "new-psdrive -Name 'par' -PSProvider Variable -Root 'c:\tmp'" >>  tmp_robot_bake_prep_$$.ps1
echo "\$ssm_bake_uid='ec2-user'" 					>> tmp_robot_bake_prep_$$.ps1
echo "\$ssm_bake_key='tmp_bake_$$'" 					>> tmp_robot_bake_prep_$$.ps1
./env_def/read_ps_variables.sh powershell/robot_bake_user_data.ps1 	>> tmp_robot_bake_prep_$$.ps1
cat powershell/robot_bake_user_data.ps1 				>> tmp_robot_bake_prep_$$.ps1
echo "</powershell>" 							>> tmp_robot_bake_prep_$$.ps1
sed -i "s/$/\r/" 							   tmp_robot_bake_prep_$$.ps1

unix2dos 								 ./tmp_robot_bake_prep_$$.ps1

echo "3. Start Windows EC2 instance and install"
crms_tmp_sec_group_id=$(aws ec2 create-security-group --group-name "tmpBAKE-RDP-$env_id$$" --description "CRMS-BAKE-RDP" --vpc-id $VPCID|jq ".GroupId"|sed "s/\"//g")
aws ec2 authorize-security-group-ingress --group-id $crms_tmp_sec_group_id --ip-permissions IpProtocol=tcp,FromPort=3389,ToPort=3389,IpRanges="[{CidrIp=$SSHACCESSCIDR,Description=\"WinRM for baking\"}]"
aws ec2 create-key-pair --key-name "tmpkey-CRMS-ROBOT-$env_id$$" --query 'KeyMaterial' --output text > tmp_bake_robot_$env_id.pem
chmod g-rw tmp_bake_robot_$env_id.pem
chmod o-rw tmp_bake_robot_$env_id.pem


#Create KMS_EC2 if not exists
kms_ec2_keyid=$(./aws/aws_get_parameter.sh $KMS_EC2)
if [[ $kms_ec2_keyid == 'null' ]]; then
        envsubst < aws/CRMS_CFM/template/kms_policy_ami_template.json > kms_policy_ami_$$.json
        kms_ec2_keyid=$(aws kms create-key --policy file://kms_policy_ami_$$.json|jq -r '.KeyMetadata.KeyId')
	#CAST requirement to enable key rotation
        aws kms enable-key-rotation --key-id $(echo $kms_ec2_keyid|sed 's/^.*\///')
        ./aws/aws_put_parameter.sh $KMS_EC2 $kms_ec2_keyid
fi

#Always use the latest image
ami_id=$(curl https://hip.ext.national.com.au/images/aws/windows/2016/latest)
aws ec2 describe-images --image-id $ami_id|jq -r '.Images[].BlockDeviceMappings|del(.[]|select (.Ebs == null))|del(.[].Ebs.SnapshotId)|.[].Ebs.Encrypted=true|.[].Ebs.KmsKeyId="'$kms_ec2_keyid'"' > encrypted_device_mapping_$$.json



instance_id=`\
aws ec2 run-instances \
    --block-device-mappings file://encrypted_device_mapping_$$.json \
    --subnet-id $SUBNETID1 \
    --security-group-ids $crms_tmp_sec_group_id \
    --image-id $ami_id \
    --instance-type t3.large \
    --key-name "tmpkey-CRMS-ROBOT-$env_id$$" \
    --iam-instance-profile Name=$IAM_PROFILE_PROV \
    --user-data file://tmp_robot_bake_prep_$$.ps1 \
    | jq ".Instances[0]|.InstanceId"|sed "s/\"//g"`
aws ec2 create-tags --resources $instance_id --tags \
	Key=CostCentre,Value=$T_CostCentre \
	Key=ApplicationID,Value=$T_ApplicationID \
	Key=Environment,Value=$T_Environment \
	Key=AppCategory,Value=$T_AppCategory \
	Key=SupportGroup,Value=$T_SupportGroup \
	Key=PowerMgt,Value=NA \
	Key=Name,Value=CRMSWIDA0000
echo "- Wait for instance status OK and Password Ready"
aws ec2 wait instance-status-ok --instance-ids $instance_id
aws ec2 wait password-data-available --instance-id $instance_id

echo "- Get windows password" and wait for the installation to complete
pwd=$(aws ec2 get-password-data --instance-id $instance_id --priv-launch-key tmp_bake_robot_$env_id.pem | jq -r .PasswordData)
ip=$(aws ec2 describe-instances --instance-id $instance_id | jq -r ".Reservations|.[0]|.Instances|.[0]|.PrivateDnsName")
echo $ip $pwd
./aws/aws_put_parameter.sh pwd_$AWS_PAR_ROBOT_IMAGE "'"$pwd"'"

echo "Wait for installation to complete"
while ! grep -q "DONE\!"  /tmp/status_$$.txt 2>/dev/null; do
        sleep 5
        cat  /tmp/status_$$.txt 2>/dev/null
done

echo "- Create image form this instance "
TS=`date +%Y-%m-%d-%H-%M-%S`
image_id=`aws ec2 create-image --name CRMS_ROBOT_IMAGE$TS --instance-id $instance_id|jq ".ImageId"|sed "s/\"//g"`
aws ec2 create-tags --resources $image_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt 

echo "- wait for image to be created"
aws ec2 wait image-available --image-ids $image_id
sleep 5

echo "- Wait for image to be available"
while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
do
        sleep 30
done


echo "- Add image to aws parameter store"
./aws/aws_put_parameter.sh $AWS_PAR_ROBOT_IMAGE $image_id 

