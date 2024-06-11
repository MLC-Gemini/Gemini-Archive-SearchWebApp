#!/usr/bin/bash

cleanup() {
        echo "9. Drop this instance"
        aws cloudformation delete-stack \
            --region ap-southeast-2 \
            --stack-name GeminiBakeDev$ts
        aws cloudformation wait stack-delete-complete --stack-name GeminiBakeDev$ts
        tmp_gemini_web_bake_$env_id.pem
                 rm -f kms_policy_ami_$$.json
                 rm -f encrypted_device_mapping_$$.json
                 rm -f geminiarchive-app.key
                 rm -f geminiarchive-app.pem
                 rm -f privatekey.pem
                 rm -f certificate.pem
                 rm -f certificatechain.pem
        echo "Baking Done ."
}
#trap cleanup EXIT

#env_id="nonprod"
env_id=$1
source ./Batch/var/read_variables.sh $env_id
ts=`date +%Y-%m-%d-%H-%M-%S`

echo "1. Download from artifactory"
./Batch/get_gemini_web_artifact.sh $env_id /tmp/gemini_web_staging

echo "2. Run instance using latest golden image in Baking VPC"
ami_id=$(aws ec2 describe-images --filters "Name=name,Values=RHEL8Golden*" --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' --output 'text')
ec2instanceSG=$(aws ssm get-parameter  --name "/gemini_archive_web/ec2instanceSG" --query "Parameter.Value" --output text)

sed -e "s/oldAMI/$ami_id/g;s/oldSG/$ec2instanceSG/g" template/dev-rhel8.json_template > dev-rhel8.json

echo $ami_id

aws cloudformation deploy --region ap-southeast-2 --stack-name GeminiBakeDev$ts \
    --template-file cloudformation/ec2-launchtemplate-key.yaml \
    --capabilities CAPABILITY_NAMED_IAM --parameter-overrides file://dev-rhel8.json

instance_id=`aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId[]" \
    --filters "Name=tag-key,Values=aws:cloudformation:stack-name" "Name=tag-value,Values=GeminiBakeDev$ts" --output=text`

echo $instance_id

echo "- Wait for instance status OK"
aws ec2 wait instance-status-ok --instance-ids $instance_id

endpoint=`aws ec2 describe-instances --instance-ids $instance_id | jq ".Reservations[0]|.Instances[0]|.PrivateIpAddress"|sed "s/\"//g"`
echo $endpoint;

#To avoid potential Man in the middle issue
sed -i "/$endpoint/d" ~/.ssh/known_hosts

keypair=`aws ec2 describe-instances --query "Reservations[*].Instances[*].KeyName[]" \
    --filters "Name=tag-key,Values=aws:cloudformation:stack-name" "Name=tag-value,Values=GeminiBakeDev$ts" --output=text`

keyid=`aws ec2 describe-key-pairs --filters Name=key-name,Values=$keypair --query KeyPairs[*].KeyPairId --output text`

aws ssm get-parameter --name /ec2/keypair/$keyid --with-decryption --query Parameter.Value --output text > tmp_gemini_web_bake_$env_id.pem
chmod g-rw tmp_gemini_web_bake_$env_id.pem
chmod o-rw tmp_gemini_web_bake_$env_id.pem

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

echo "3. Setuping SSL certificate form AWS ACM certificate parameter"
# Downloading SSL certificate from AWS SSM parameter store in require format to store in AWS IAM.
ssl_passphrase=`aws ssm get-parameters --name $SSL_PASSPHRASE --with-decryption --region "ap-southeast-2" | jq -r '.Parameters[0].Value'`
aws ssm get-parameter --name $SSL_KEY --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > privatekey_enc.key
openssl rsa -in privatekey_enc.key -out privatekey.key -passin pass:$ssl_passphrase
aws ssm get-parameter --name $SSL_CERT --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > certificate.pem
aws ssm get-parameter --name $SSL_CHAIN1 --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > certificatechain.pem
aws ssm get-parameter --name $SSL_CHAIN2 --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value >> certificatechain.pem

# Downloading the SSL certificate for Ec2 backend server (key and cert) file from AWS SSM parameter store and outputting to local file
aws ssm get-parameter --name $SSL_KEY --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > geminiarchive-app-enc.key
openssl rsa -in geminiarchive-app-enc.key -out geminiarchive-app.key -passin pass:$ssl_passphrase
aws ssm get-parameter --name $SSL_CERT --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > geminiarchive-app.pem
aws ssm get-parameter --name $SSL_CHAIN1 --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value >> geminiarchive-app.pem
aws ssm get-parameter --name $SSL_CHAIN2 --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value >> geminiarchive-app.pem

echo "4. Configurting ASP.NET secret form AWS SSM parameter store value"
Rds_server=`aws ssm get-parameters --name $SSM_RDS_SERVER --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
Rds_uname=`aws ssm get-parameters --name $SSM_RDS_UNAME --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
Rds_pass=`aws ssm get-parameters --name $SSM_RDS_PASS --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
Rdsconstr="Server="$Rds_server";Database=image;MultipleActiveResultSets=true;User Id="$Rds_uname";Password="$Rds_pass";"
Adgroup=`aws ssm get-parameters --name $SSM_ADGROUP --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
TibcoImageEBF_url=`aws ssm get-parameters --name $SSM_TIBCO_IMAGEEBF_URL --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
TibcoImageEBF_uid=`aws ssm get-parameters --name $SSM_TIBCO_IMAGEEBF_SRV_UID --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
TibcoImageEBF_pass=`aws ssm get-parameters --name $SSM_TIBCO_IMAGEEBF_SRV_PASS --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
LdapServerName=`aws ssm get-parameters --name $SSM_LDAP_SERVER_NAME --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
LdapServerPort=`aws ssm get-parameters --name $SSM_LDAP_SERVER_PORT --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
LdapBaseDn=`aws ssm get-parameters --name $SSM_LDAP_SERVER_BASEDN --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`
LdapDomain=`aws ssm get-parameters --name $SSM_LDAP_SERVER_DOMAIN --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`

if [[ $Rdsconstr != 'null' && $Adgroup != 'null' && $TibcoImageEBF_uid != 'null' && $TibcoImageEBF_pass != 'null' ]]; then
# exporting the varibale needed for kms json template files.
  export RDSCONSTR="${Rdsconstr}"
  export ADGROUP="${Adgroup}"
  export TIBCOIMAGEEBF_URL="${TibcoImageEBF_url}"
  export TIBCOIMAGEEBF_UID="${TibcoImageEBF_uid}"
  export TIBCOIMAGEEBF_PASS="${TibcoImageEBF_pass}"

  export LDAPSERVERNAME="${LdapServerName}"
  export LDAPSERVERPORT="${LdapServerPort}"
  export LDAPBASEDN="${LdapBaseDn}"
  export LDADOMAIN="${LdapDomain}"

  envsubst < Published/appsettings.json > tmp-appsettings.json

# Delete origin appsettings.json and replace with secrets form AWS SSM Parameter Store
  rm -r Published/appsettings.json
  mv tmp-appsettings.json Published/appsettings.json
fi

echo "5. Copy source code to image"
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem /tmp/gemini_web_staging/* ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/ec2_install_software.sh ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/nginx.service ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Published ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/kestrel-geminiweb.service ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/nginx.conf ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem Batch/config_batch_ad.sh ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem geminiarchive-app.key ec2-user@$endpoint:/tmp
scp -o StrictHostKeyChecking=no -r -i tmp_gemini_web_bake_$env_id.pem geminiarchive-app.pem ec2-user@$endpoint:/tmp

echo "6. Change the SELINX setting to disabled from enforcing"
ssh -i tmp_gemini_web_bake_$env_id.pem ec2-user@$endpoint 'sudo sed -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config > /etc/selinux/config_new; mv /etc/selinux/config_new /etc/selinux/config'
aws ec2 reboot-instances --instance-ids $instance_id
aws ec2 wait instance-running --instance-ids $instance_id
#Leave a few minutes to ensure instance is ssh ready
sleep 3m

echo "7. Run SSH(ec2_install_software.sh) to install software"
ssh -i tmp_gemini_web_bake_$env_id.pem ec2-user@$endpoint 'sudo chmod +x /tmp/ec2_install_software.sh; sudo /tmp/ec2_install_software.sh'
ssh -i tmp_gemini_web_bake_$env_id.pem ec2-user@$endpoint 'sudo rm /tmp/ec2_install_software.sh'
ssh -i tmp_gemini_web_bake_$env_id.pem ec2-user@$endpoint 'sudo rm -r /tmp/Published'

echo "8. Create image form this instance"
image_id=`aws ec2 create-image --name GEMINI_WEB_IMAGE$ts --instance-id $instance_id|jq ".ImageId"|sed "s/\"//g"`
aws ec2 create-tags --resources $image_id --tags Key=PatchCycle,Value=$T_PatchCycle Key=Environment,Value=$T_Environment Key=T_CostCentre,Value=$T_CostCentre Key=DataClassification,Value=$T_DataClassification Key=Owner,Value=$T_Owner Key=PowerMgt,Value=$T_PowerMgt Key=Name,Value=$T_Name Key=ApplicationID,Value=$T_ApplicationID Key=OUName,Value=$T_OUName Key=map-migrated,Value=$T_MapMigrated

echo "- wait for image to be created"
aws ec2 wait image-available --image-ids $image_id
echo "- Wait for image to be available"
while [ "$(aws ec2 describe-images --image-id $image_id | jq -r '.Images[0].State')" != "available" ]
do
        sleep 30
done

echo "9. Add encrypted image to aws parameter store"
aws ssm put-parameter --name $AWS_PAR_BATCH_IMAGE --value $image_id --type "SecureString" --region "ap-southeast-2" --overwrite
