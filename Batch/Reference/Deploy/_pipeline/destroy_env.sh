#_pipeline/destroy_env.sh $dbname rds-delete-password-$dbname
#_pipeline/destroy_env.sh $dbname $(aws/aws_get_parameter.sh rds-delete-password-$dbname)

dbname=$1
rds_password=$2

_pipeline/destroy_robot_server.sh $dbname 
_pipeline/destroy_rds.sh $dbname $rds_password
aws cloudformation delete-stack --stack-name CRMS-NETWORK-$dbname
aws cloudformation wait stack-delete-complete --stack-name CRMS-NETWORK-$dbname
