ROLE_ARN=$1

aws configure set default.region $REGION
#unset AWS_ACCESS_KEY_ID ; $( aws sts assume-role --role-arn arn:aws:iam::$ROLE_ARN --role-session-name "CRMS_TEMP_ROLE" | grep -E '(SecretAccessKey|SessionToken|AccessKeyId)' | awk '{print $2}' | tr -d ',' | awk 'NR==1 { system("echo export AWS_SECRET_ACCESS_KEY="$1) }; NR==2 { system("echo export AWS_SECURITY_TOKEN="$1) } ; NR==3 { system("echo export AWS_ACCESS_KEY_ID="$1) }' )

#duration seconds set to 2 hours for large database snapshots
#HipOps have advised that this is temporary ##TODO
aws sts assume-role --role-arn arn:aws:iam::$ROLE_ARN --role-session-name "CRMS_TEMP_ROLE_$(uuidgen)" > tmp_assume_role_$$
#--duration-seconds "7200"
export AWS_SECRET_ACCESS_KEY=$(cat tmp_assume_role_$$|jq -r '.Credentials.SecretAccessKey')
export AWS_SECURITY_TOKEN=$(cat tmp_assume_role_$$|jq -r '.Credentials.SessionToken')
export AWS_ACCESS_KEY_ID=$(cat tmp_assume_role_$$|jq -r '.Credentials.AccessKeyId')

rm tmp_assume_role_$$
