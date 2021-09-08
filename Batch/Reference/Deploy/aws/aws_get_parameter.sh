PAR_NAME=$1
#aws ssm get-parameters --name $PAR_NAME --with-decryption --region ap-southeast-2| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'
aws ssm get-parameters --name $PAR_NAME --with-decryption --region ap-southeast-2| jq -r '.Parameters[0].Value'
