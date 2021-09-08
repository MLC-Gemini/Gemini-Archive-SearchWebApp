#_pipeline/create_db.sh CRMST02 [arn:aws:rds:ap-southeast-2:040653843081:snapshot:crmsdv02-full-with-attachement CRMSD02 "DC_Exit,DC_EXIT_ST_CREATE_DB,DCEXIT_MARCH,DCEXIT_2019_11"]

#set -e

cleanup() {
	rm kms_policy_rds_$$.json 2>/dev/null
	rm tmp_rds_opt_grp_$$.json 2>/dev/null
  if [ "${exit_code}" = "1" ]; then
    echo "Error creating db, check working folder(create_db.sh=$Git_Working_Folder)"
    echo "Please delete working folder after issue is fixed"
  else
	  rm -rf $Git_Working_Folder        
  fi
}
trap cleanup EXIT


exit_code=0
dbname=CRMST03
db_snapshot_arn=arn:aws:rds:ap-southeast-2:040653843081:snapshot:crmsdv02-full-with-attachement
db_clone_from=CRMST02
apply_releases="DC_Exit,DC_EXIT_ST_CREATE_DB,DCEXIT_MARCH,DCEXIT_2019_11"

dbname=$1
db_snapshot_arn=$2
db_clone_from=$3
apply_releases=$4

source aws/checkout_stable_release.sh $dbname

#check for whether oracle is installed, and if not, install oracle instant client
bash db/jenkins_install_oracle.sh $dbname

./_pipeline/_prepare_environment.sh $dbname
#Below script returns RDS Option Group ID $Rds_Option_Group_Id
source ./aws/aws_get_rds_option_group.sh $dbname

source ./aws/aws_assume_role.sh $CRMS_PROV_ROLE_ID
master_db_pwd=$(./aws/aws_get_parameter.sh $DBPWD)
if [[ $master_db_pwd == ''  || $master_db_pwd == 'null' ]]; then
        master_db_pwd=$(openssl rand -base64 10)
        ./aws/aws_put_parameter.sh $DBPWD $master_db_pwd
fi

#Always use DBNAME as instance name
db_instance_id=${dbname,,}

#Generate random password, put it in parameter store, this password will be used for deleting this stack in _pipeline/destory_rds.sh
aws/aws_put_parameter.sh rds-delete-password-$dbname $(openssl rand -hex 8)

#Create KMS_RDS if not exists
kms_rds_arn=$(./aws/aws_get_parameter.sh $KMS_RDS)
if [[ $kms_rds_arn == '' || $kms_rds_arn == 'null' ]]; then
        envsubst < aws/CRMS_CFM/template/kms_policy_rds_template.json > kms_policy_rds_$$.json
        kms_rds_arn=$(aws kms create-key --policy file://kms_policy_rds_$$.json|jq -r '.KeyMetadata.Arn')
	#CAST requirement to enable key rotation
	aws kms enable-key-rotation --key-id $(echo $kms_rds_arn|sed 's/^.*\///')
        aws kms create-alias --alias-name alias/$KMS_RDS --target-key-id $(echo $kms_rds_arn|sed 's/^.*\///')
        ./aws/aws_put_parameter.sh "$KMS_RDS" "$kms_rds_arn"
fi

#check whether snapshot is shared, and if so, copy shared snapshot to a manual snapshot
rds_snapshot_type=$(aws rds describe-db-snapshots --db-snapshot-identifier $db_snapshot_arn | jq -r '.DBSnapshots[].SnapshotType')
if [[ $rds_snapshot_type == 'shared' ]]; then

        echo "Copy shared snapshot to a manual snapshot"
        non_prod_copy_name=snap-crms-prod-copy-$(date +%Y-%m-%d-%H-%M-%S)

        #1. Copy snapshot from External Account to local
        aws rds copy-db-snapshot --source-db-snapshot-identifier  $db_snapshot_arn --target-db-snapshot-identifier $non_prod_copy_name --kms-key-id $kms_rds_arn --option-group-name $Rds_Option_Group_Id
        
        #2. Wait for copy to complete
        while [ "${exit_status}" != "0" ]
        do
                aws rds wait db-snapshot-completed --db-snapshot-identifier $non_prod_copy_name
                exit_status="$?"
        done

        #3. Register current snapshot name in SSM store
        aws/aws_put_parameter.sh $SNAP_PROD_COPY $non_prod_copy_name

        #use new snapshot for database refresh
        db_snapshot_arn=${non_prod_copy_name,,}
        
fi

#Pre-refresh
if [[ $(aws rds describe-db-instances|jq -r '.DBInstances[]|select (.DBInstanceIdentifier=="'${dbname,,}'").DBInstanceIdentifier'|wc -l) == 0 ]]; then
	if [[ $db_clone_from != '' ]]; then
		Exp_file_name=pre_refresh-$dbname-$$.dmp
		db/refresh_pre.sh $db_clone_from $Exp_file_name
	else
		#Clone from database is unknow
		echo "Looks like this is the first time database to be created, continue refresh process without post refresh process"
                Exp_file_name=''
	fi
else
	Exp_file_name=pre_refresh-$dbname-$$.dmp
	if [[ $db_clone_from == '' ]]; then
		db/refresh_pre.sh $dbname $Exp_file_name
	else
		db/refresh_pre.sh $db_clone_from $Exp_file_name
	fi
	#Rename db-instance name so that new instance with the same db-instance name can be created
	#TODO: Need drop this database after refresh process is successfully completed and verified
	aws rds modify-db-instance --db-instance-identifier $db_instance_id --new-db-instance-identifier $db_instance_id-$(date +%F%H%M%S|sed "s/-//g") --apply-immediately
	#Wait until db-instance name change completed
        while [[ "$(aws rds describe-db-instances | jq -r '.DBInstances[]|select (.DBInstanceIdentifier=="'$db_instance_id'").DBInstanceIdentifier')" == "$db_instance_id" ]]
        do
                echo "Wait for instance name to be changed"
                sleep 30
        done

fi


if [[ $db_snapshot_arn != '' ]]; then
        #Restore a database from a snapshot
	#TODO:Refresh from a snapshot, this is the standard method for now, we need DB subset to save some money down the track
        aws rds restore-db-instance-from-db-snapshot \
        --db-instance-identifier $db_instance_id \
        --db-snapshot-identifier $db_snapshot_arn \
	--vpc-security-group-ids $(aws cloudformation describe-stack-resources --stack-name CRMS-NETWORK-$dbname|jq -r '.StackResources[]|select (.LogicalResourceId=="RDSDBSecurityGroup").PhysicalResourceId') \
        --db-subnet-group-name $(aws cloudformation describe-stack-resources --stack-name CRMS-NETWORK-$dbname|jq -r '.StackResources[]|select (.LogicalResourceId=="CRMSDBSubnetGroup").PhysicalResourceId') \
        --db-parameter-group-name $(aws cloudformation describe-stack-resources --stack-name CRMS-NETWORK-$dbname|jq -r '.StackResources[]|select (.LogicalResourceId=="CRMSDBParameterGRP").PhysicalResourceId') \
        --db-instance-class $DBCLASS \
        --port $DBPORT \
        --db-name $dbname \
        --engine oracle-ee \
	--option-group-name $Rds_Option_Group_Id \
        --enable-cloudwatch-logs-exports '["trace","audit","alert","listener"]' \
	--tags "$(envsubst < aws/CRMS_CFM/template/rds_tags_template.json)"
        #--iops $IOPS \
        #--storage-type $STORAGETYPE \
                #"CRMSDBParameter=CRMS-DB-Parameter-Group-opt-$dbname" \
                #"KmsKeyId=$kms_rds_arn" \
                #"MultiZone=$MULTIAZ" \

        while [ 1 ];
        do
                echo "Wait for instance available"
                sleep 60
                aws rds wait db-instance-available --db-instance-identifier $db_instance_id
                if [ "$?" == "0" ]; then break; fi;                
        done

	echo "Reset Admin Account password"
	aws rds modify-db-instance --db-instance-identifier $db_instance_id --master-user-password $master_db_pwd --apply-immediately

	echo "Wait until database password change complete"
	while [[ $(aws rds describe-db-instances --db-instance-identifier $db_instance_id|jq -r ".DBInstances[0].PendingModifiedValues.MasterUserPassword") != 'null' ]]
	do
		echo "Wait for password to be reset"
		sleep 60
	done

	echo "Create/recreate crms_install schema"
	source ./db/set_oracle_env.sh $dbname
	sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$dbname" @db/sql/crms_install.sql $(./env_def/crms_decrypt $CRMS_INSTALL_PWD)

	echo "Populate crms_install.crms_parameter details"
	echo "DBA-import parameter from environment file"
	echo "set define off" > rp_$$.sql
	./env_def/read_variables.sh $dbname DB >>  rp_$$.sql
	echo "commit;
	quit;" >> rp_$$.sql
	sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$dbname" @rp_$$.sql
	rm rp_$$.sql

        echo "Configure CRMS SSL for RDS to access EVO etc"
        sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$dbname" @db/sql/Configure_CRMS_SSL.sql

        echo "$0-3 Reset crms password using master account"
        crms_pwd=$(./env_def/crms_decrypt $CRMS_PWD)
        sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$target_db" @db/sql/change_crms_password.sql $CRMS_UID $crms_pwd       

	echo "Recreate tbl_config, this table should be standard across all databases"
	#Create crms_config_set procedure which is used in promotion code
	cat db/subsetting/schema/tbl_config.sql db/sql/sp/crms_config_set.sql > tmp_sql_$$.sql
	echo "quit;" >> tmp_sql_$$.sql
	sqlplus -s "$CRMS_UID/$crms_pwd@$dbname" @tmp_sql_$$.sql
	rm tmp_sql_$$.sql
	
	echo "Upload EVO/Tibco Wallet"
	./db/upload_wallet.sh $dbname

	echo "Apply releases specified in the parameter 'apply_releases'"
	IFS=',';read -ra release_id <<< "$apply_releases";unset IFS
	for i in "${release_id[@]}"
	do
        	./_pipeline/promote_crms_specific.sh $BUILD_STAGE $i $dbname Y
	done

	echo "Only do post refresh if dbsnapshot is provided"
        if [[ $Exp_file_name != '' ]]; then
                echo "$0-4. Export all table columns to see if there is any changes between pre-post DB"
                source ./db/set_oracle_env.sh $dbname
                sqlplus -s "$CRMS_UID/$crms_pwd@$dbname" > $Exp_file_name.cols_post << !!
                set heading off
                set linesize 10000
                set PAGESIZE 0
                SET LONG 90000
                SET FEEDBACK OFF
                SET ECHO OFF
                select
                tbl_config.table_name||': '||
                (select listagg(column_name,',') within group (order by column_id) from all_tab_cols where owner='CRMS' and table_name=tbl_config.table_name and column_id is not null )
                from tbl_config
                where upper(refresh_keep)='Y'
		order by table_name;
                quit;
!!
                pre_post_diff=$(diff $Exp_file_name.cols_pre $Exp_file_name.cols_post)
                if [[ "$pre_post_diff" == "" ]]; then
                        db/refresh_post.sh $dbname $CRMS_ADMIN_UID $master_db_pwd $CRMS_UID $crms_pwd $Exp_file_name
                        #Apply environment specific configuration data
                        sqlplus -s "$CRMS_UID/$crms_pwd@$dbname" @db/sql/set_environment_specific_config.sql
                        sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$target_db" @db/sql/change_crms_password.sql 'work_ebf' $(./env_def/crms_decrypt $WORK_EBF_PWD)       
                else
                        #TODO: SNS Topic and send notification
                        echo "#Warning!!!                                                                 #"
                        echo "#                                                                           #"
                        echo "Pre-Post schemas are different, please fix & run post refresh script manually "
                        echo "#                                                                           #"
                        echo "To see diff: diff $Exp_file_name.cols_pre $Exp_file_name.cols_post"
                        echo "#                                                                           #"
                        echo "To force a refresh: db/refresh_post.sh $dbname $CRMS_ADMIN_UID $master_db_pwd $CRMS_UID $crms_pwd $Exp_file_name"
                        echo "#                                                                           #"
                        echo "And don't forget to do this: source ./db/set_oracle_env.sh $dbname; sqlplus -s $CRMS_UID/$crms_pwd@$dbname @db/sql/set_environment_specific_config.sql"
                        echo "#                                                                           #"
                        echo "and this: ./aws/aws_update_rds_dns.sh $dbname"
                        echo "#                                                                           #"
                        support_topic_arn=$(aws sns create-topic --name SNS_Support_$T_Environment | jq -r '.TopicArn') 
                        aws sns publish --topic-arn $support_topic_arn --message "#Warning: $dbname pre & post schemas are different. Please check log, fix & run post refresh script manually."
                        exit_code=1
                        exit 1
                fi
        else
                sqlplus -s "$CRMS_UID/$crms_pwd@$dbname" @db/sql/set_environment_specific_config.sql
                sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$target_db" @db/sql/change_crms_password.sql 'work_ebf' $(./env_def/crms_decrypt $WORK_EBF_PWD)       
                sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$target_db" @db/sql/change_crms_password.sql 'reporting' $(./env_def/crms_decrypt $REPORTING_PWD)                       
                sqlplus -s "$CRMS_ADMIN_UID/$master_db_pwd@$target_db" @db/sql/create_user_digital.sql
        fi
else
        #Create new database
        aws cloudformation deploy --template-file aws/CRMS_CFM/CRMSRDS.template --stack-name CRMS-RDS-$dbname --parameter-overrides \
                "DBInstanceClass=$DBCLASS" \
                "AllocatedStorage=$DBSIZE" \
                "DBInstanceIdentifier=$db_instance_id" \
                "DBInstanceName=$dbname" \
                "MasterDBPassword=$master_db_pwd" \
                "DBPort=$DBPORT" \
                "NetworkStackName=CRMS-NETWORK-$dbname" \
                "DBName=$dbname" \
                "DBSnapshotARN=$db_snapshot_arn" \
                "CRMSDBParameter=CRMS-DB-Parameter-Group-opt-$dbname" \
                "Iops=$IOPS" \
                "KmsKeyId=$kms_rds_arn" \
                "StorageType=$STORAGETYPE" \
                "EngineVersion=$CRMS_RDS_VER" \
                "MajorEngineVersion=$CRMS_RDS_MAJOR_VER" \
                "MultiZone=$MULTIAZ" \
                "CRMSDBOptionGRP=$Rds_Option_Group_Id" \
        --tags \
        "CostCentre=$T_CostCentre" \
        "ApplicationID=$T_ApplicationID" \
        "Environment=$T_Environment" \
        "AppCategory=$T_AppCategory" \
        "SupportGroup=$T_SupportGroup" \
        "Name=$dbname" \
        "PowerMgt=$T_RDS_PowerMgt"
fi

if [ $? == 0 ]; then

	if [[ $CRMS_RDS_DNS != '' ]]; then
		#Route53
        	./aws/aws_update_rds_dns.sh $dbname 
	fi

	_pipeline/create_cloud_watch_rds.sh $dbname

        while [ 1 ];
        do
                echo "Wait for instance available"
                sleep 60
                aws rds wait db-instance-available --db-instance-identifier $db_instance_id
                if [ "$?" == "0" ]; then break; fi;
        done

	#setup automated backups - this is temporary while we wait for the RDS backup strategy to be set
	aws rds modify-db-instance --db-instance-identifier $db_instance_id --backup-retention-period $RDS_BACKUP_RETENTION --copy-tags-to-snapshot --apply-immediately

	aws rds reboot-db-instance --db-instance-identifier $dbname

else
  exit_code=1
fi
