#_pipeline/create_db_from_prod_snapshot.sh CRMSD03 arn:aws:rds:ap-southeast-2:638918978875:snapshot:crms-w-er190716-201907161549-201907171625-shared
dbname=$1
prod_snapshot_arn=$2
./_pipeline/_prepare_environment.sh $dbname
source aws/checkout_stable_release.sh $dbname
source ./aws/aws_get_rds_option_group.sh $dbname

non_prod_copy_name=snap-crms-prod-copy-$(date +%Y-%m-%d-%H-%M-%S)
#1. Copy snapshot from External Account to local

#Create KMS_RDS if not exists
kms_rds_arn=$(./aws/aws_get_parameter.sh $KMS_RDS)
if [[ $kms_rds_arn == 'null' ]]; then
        envsubst < aws/CRMS_CFM/template/kms_policy_rds_template.json > kms_policy_rds_$$.json
        kms_rds_arn=$(aws kms create-key --policy file://kms_policy_rds_$$.json|jq -r '.KeyMetadata.Arn')
	#CAST requirement to enable key rotation
	aws kms enable-key-rotation --key-id $(echo $kms_rds_arn|sed 's/^.*\///')
        ./aws/aws_put_parameter.sh "$KMS_RDS" "$kms_rds_arn"
fi

aws rds copy-db-snapshot --source-db-snapshot-identifier  $prod_snapshot_arn --target-db-snapshot-identifier $non_prod_copy_name --kms-key-id $kms_rds_arn --option-group-name $Rds_Option_Group_Id

#2. Wait for copy to complete
while [ "${exit_status}" != "0" ]
do
    aws rds wait db-snapshot-completed --db-snapshot-identifier $non_prod_copy_name
      exit_status="$?"
done

#3. Register current snapshot name in SSM store
aws/aws_put_parameter.sh $SNAP_PROD_COPY $non_prod_copy_name

#4. Create DB from local snapshot
_pipeline/create_db.sh $dbname $non_prod_copy_name
rm -rf $Git_Working_Folder
