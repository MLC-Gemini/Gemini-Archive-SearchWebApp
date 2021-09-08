par_name=$1
par_value=$2
#aws ssm put-parameter --name "$1" --value "$2" --type "String" --region "ap-southeast-2" --overwrite
aws ssm put-parameter --name "$1" --value "$2" --type "SecureString" --region "ap-southeast-2" --overwrite
