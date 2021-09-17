#_pipeline/destroy_rds.sh CRMSD03 rds-delete-password-CRMSD03 [api]
#_pipeline/destroy_rds.sh CRMSD03 $(aws/aws_get_parameter.sh rds-delete-password-CRMSD03) [api]
dbname=$1

rds_delete_password=$(aws/aws_get_parameter.sh rds-delete-password-$dbname)

if [[ "$rds_delete_password" != "" ]]; then
	if [[ "$2" != "$rds_delete_password" ]]; then
		echo "Please enter password for deleting database"
		exit 1
	fi
fi


if [[ $3 == 'api' ]];then
	aws rds delete-db-instance --db-instance-identifier $dbname --delete-automated-backups --skip-final-snapshot
	aws rds wait db-instance-deleted --db-instance-identifier $dbname
else

db_instance_id=$( aws cloudformation describe-stack-resources --stack-name CRMS-RDS-$dbname \
                      | jq -r '.StackResources[0]|select (.ResourceType=="AWS::RDS::DBInstance").PhysicalResourceId')

echo "Deleting the stack CRMS-RDS-$dbname ..."
aws cloudformation delete-stack --stack-name CRMS-RDS-$dbname 
aws cloudformation wait stack-delete-complete --stack-name CRMS-RDS-$dbname
sleep 5
if [ "$(aws cloudformation describe-stacks --stack-name CRMS-RDS-$dbname|jq -r '.Stacks[0].StackStatus')" != "DELETE_COMPLETED" ]; then
	echo "Delete stack failed, deleting last snapshot ..."
	#In case there are more than 1 snapshot left
	db_snapshots_to_be_deleted=$(
		aws rds describe-db-snapshots --db-instance-identifier $db_instance_id | jq -r '.DBSnapshots[].DBSnapshotIdentifier'
	)
	for i in $db_snapshots_to_be_deleted
	do
		aws rds delete-db-snapshot --db-snapshot-identifier $i 
	done
	
	for i in $db_snapshots_to_be_deleted
	do
		aws rds wait db-snapshot-deleted --db-snapshot-identifier $i
	done
	
	sleep 5
	echo "Deleting the stack again ..."
	aws cloudformation delete-stack --stack-name CRMS-RDS-$dbname 
	aws cloudformation wait stack-delete-complete --stack-name CRMS-RDS-$dbname
fi
fi

