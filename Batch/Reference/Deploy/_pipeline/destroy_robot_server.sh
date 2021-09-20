#_pipeline/destroy_robot_server.sh CRMSD03 
dbname=$1

aws cloudformation delete-stack --stack-name CRMS-ROBOT-$dbname
aws cloudformation wait stack-delete-complete --stack-name CRMS-ROBOT-$dbname
