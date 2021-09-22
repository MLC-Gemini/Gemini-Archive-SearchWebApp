cleanup() {
	echo "6. Drop this instance"
	aws ec2 terminate-instances --instance-ids $instance_id
	rm tmp_gemini_web_bake_$env_id.pem
	aws ec2 delete-key-pair --key-name "tmpkey-GEMINI-WEB-$env_id$$"
	aws ec2 wait instance-terminated --instance-ids $instance_id
	aws ec2 delete-security-group --group-id $geminiweb_tmp_sec_group_id

	rm -f kms_policy_ami_$$.json
	rm -f encrypted_device_mapping_$$.json
	#$Git_Working_Folder value is returned by aws/checkout_stable_release.sh
	#rm -rf $Git_Working_Folder
	echo "Baking Done ."
}
trap cleanup EXIT

#env_id="nonprod"
env_id=$1
source ./Batch/var/read_variables.sh $env_id

echo "1. Download from artifactory"
./Batch/get_gemini_web_artifact.sh $env_id /tmp/gemini_web_staging

echo "2. Run instance using HIP latest image in Baking VPC"
geminiweb_tmp_sec_group_id=$(aws ec2 create-security-group --group-name "GEMINI-WEB-BAKE-SSH-$env_id$$" --description "GEMINIWEB-BAKE-SSH" --vpc-id "$VPCID"|jq ".GroupId"|sed "s/\"//g")
aws ec2 authorize-security-group-ingress --group-id $geminiweb_tmp_sec_group_id --protocol tcp --port 22 --cidr $SSHACCESSCIDR
aws ec2 create-key-pair --key-name "tmpkey-GEMINI-WEB-$env_id$$" --query 'KeyMaterial' --output text > tmp_gemini_web_bake_$env_id.pem
chmod g-rw tmp_gemini_web_bake_$env_id.pem
chmod o-rw tmp_gemini_web_bake_$env_id.pem

#Encryption Option 1(current): Encrypt the root device when running the instance, this way,  we don't have to copy it as encrypted image
#Encryption Option 2: Copy to a new image with encryption

ami_id=$(curl "https://hip.ext.national.com.au/images/aws/rhel/7/latest")
kms_ec2_keyid=`aws ssm get-parameters --name $GEM_KMS --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`

if [[ $kms_ec2_keyid == 'null' ]]; then
# export the varibale needed for kms josn files.
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
	#./aws/aws_put_parameter.sh $KMS_EC2 $kms_ec2_keyid
fi
aws ec2 describe-images --image-id $ami_id|jq -r '.Images[].BlockDeviceMappings|del(.[].Ebs.SnapshotId)|.[].Ebs.Encrypted=true|.[].Ebs.KmsKeyId="'$kms_ec2_keyid'"'|sed 's/VolumeSize": .*/VolumeSize":'$BATCH_SERVER_SIZE',/' > encrypted_device_mapping_$$.json

instance_id=`\
aws ec2 run-instances \
    --block-device-mappings file://encrypted_device_mapping_$$.json \
    --subnet-id $SUBNETID1 \
    --security-group-ids $geminiweb_tmp_sec_group_id \
    --image-id $ami_id \
    --instance-type $INSTANCE_TYPE_BATCH \
    --key-name "tmpkey-GEMINI-WEB-$env_id$$" \
    --iam-instance-profile Name=$IAM_PROFILE_PROV \
    | jq ".Instances[0]|.InstanceId"|sed "s/\"//g"`
aws ec2 create-tags --resources $instance_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id

echo "- Wait for instance status OK"
aws ec2 wait instance-status-ok --instance-ids $instance_id

endpoint=`aws ec2 describe-instances --instance-ids $instance_id | jq ".Reservations[0]|.Instances[0]|.PrivateIpAddress"|sed "s/\"//g"`
echo $endpoint;

#To avoid potential Man in the middle issue
sed -i "/$endpoint/d" ~/.ssh/known_hosts

echo "- Wait for SSH ready"
echo "" > /tmp/dummy
X_READY='X'
while [ $X_READY ]; do
    echo "- Waiting for ssh ready"
    X_READY=$(scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem /tmp/dummy ec2-user@$endpoint:/tmp | grep "Permission denied")
    sleep 5
done

#When we get connection refused, X_READY will not be set any value, use below code to make sure SSH is indeed ready
index=1
maxConnectionAttempts=10
sleepSeconds=10
while (( $index <= $maxConnectionAttempts ))
do
  scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem /tmp/dummy ec2-user@$endpoint:/tmp
  case $? in
    (0) echo "${index}> Success"; break ;;
    (*) echo "${index} of ${maxConnectionAttempts}> Bastion SSH server not ready yet, waiting ${sleepSeconds} seconds..." ;;
  esac
  sleep $sleepSeconds
  ((index+=1))
done

# Getting the SSL certificate (key and cert) file from AWS SSM parameter store and outputting to local file
aws ssm get-parameter --name $SSL_KEY --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > geminiarchive-app-tst.gemini.awsnp.national.com.au.key
aws ssm get-parameter --name $SSL_CERT --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > geminiarchive-app-tst.gemini.awsnp.national.com.au.pem
aws ssm get-parameter --name $SSL_CHAIN1 --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value >> geminiarchive-app-tst.gemini.awsnp.national.com.au.pem
aws ssm get-parameter --name $SSL_CHAIN2 --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value >> geminiarchive-app-tst.gemini.awsnp.national.com.au.pem

echo "- Copy source code to image"
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem /tmp/gemini_web_staging/* ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/ec2_install_software.sh ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/nginx.service ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Published ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/kestrel-geminiweb.service ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/nginx.conf ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/ssl/* ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem geminiarchive-app-tst.gemini.awsnp.national.com.au.key ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem geminiarchive-app-tst.gemini.awsnp.national.com.au.pem ec2-user@$endpoint:/tmp

echo "3. Run SSH(ec2_install_software.sh) to install software"
ssh -i tmp_gemini_web_bake_$env_id.pem ec2-user@$endpoint 'sudo chmod +x /tmp/ec2_install_software.sh; sudo /tmp/ec2_install_software.sh'

echo "4. Create image form this instance"
ts=`date +%Y-%m-%d-%H-%M-%S`
image_id=`aws ec2 create-image --name GEMINI_WEB_IMAGE$ts --instance-id $instance_id|jq ".ImageId"|sed "s/\"//g"`
aws ec2 create-tags --resources $image_id --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=$T_Name Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut Key=HIPImage,Value=$ami_id

echo "- wait for image to be created"
aws ec2 wait image-available --image-ids $image_id
echo "- Wait for image to be available" 
while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
do 
	sleep 30
done

echo "5. Add encrypted image to aws parameter store"
#./aws/aws_put_parameter.sh $AWS_PAR_BATCH_IMAGE $image_id
aws ssm put-parameter --name $AWS_PAR_BATCH_IMAGE --value $image_id --type "SecureString" --region "ap-southeast-2" --overwrite