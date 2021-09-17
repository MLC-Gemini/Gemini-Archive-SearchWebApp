#aws/aws_get_rds_option_group.sh CRMSD02
dbname=$1

source ./env_def/read_variables.sh $dbname
envsubst < aws/CRMS_CFM/template/rds_option_group.json > tmp_rds_opt_grp_$$.json

aws cloudformation deploy --template-file tmp_rds_opt_grp_$$.json --stack-name CRMS-RDS-OPT-${VPCID}${CRMS_DB_OPTION_GRP}

Rds_Option_Group_Id=$(aws cloudformation describe-stack-resources --stack-name CRMS-RDS-OPT-${VPCID}${CRMS_DB_OPTION_GRP}|jq -r '.StackResources[]|select (.LogicalResourceId=="RDSOption").PhysicalResourceId')

rm tmp_rds_opt_grp_$$.json

export Rds_Option_Group_Id
