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

cp Batch/nginx*.tar.gz /tmp/gemini_web_staging

echo "2. Run instance using latest golden image in Baking VPC"
ami_id=$(aws ssm get-parameter  --name "/golden-ami/rhel8/latest" --query "Parameter.Value" --output text)

echo $ami_id

aws cloudformation deploy --region ap-southeast-2 --stack-name GeminiBakeDev$ts \
    --template-file cloudformation/ec2-launchtemplate-key.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides "Ami=$ami_id" "OS=rhel8" "InstanceType=t3a.small" "Environment=dev" "Platform=linux" "PatchCycle=NonProd" "Snapshot=snapn" "EC2InstanceSG=sg-0b8c950534ff7dcb5"

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

# Downloading the SSL certificate for Ec2 backend server (key and cert) file from AWS SSM parameter store and outputting to local file
aws ssm get-parameter --name $SSL_KEY --with-decryption --region "ap-southeast-2" --output text --query Parameter.Value > geminiarchive-app.key
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

  envsubst < Batch/template/appsettings.json > tmp-appsettings.json

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

