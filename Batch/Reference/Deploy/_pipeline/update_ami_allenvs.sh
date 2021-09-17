#./_pipeline/update_ami_allenvs.sh

LATEST_AMI=`aws ssm get-parameters --name CRMS_BATCH_IMAGE --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'`

aws ssm put-parameter --name CRMS_BATCH_IMAGE_PPTE --value $LATEST_AMI --type "SecureString" --region "ap-southeast-2" --overwrite
aws ssm put-parameter --name CRMS_BATCH_IMAGE_TEST --value $LATEST_AMI --type "SecureString" --region "ap-southeast-2" --overwrite
aws ssm put-parameter --name CRMS_BATCH_IMAGE_PSUP --value $LATEST_AMI --type "SecureString" --region "ap-southeast-2" --overwrite
