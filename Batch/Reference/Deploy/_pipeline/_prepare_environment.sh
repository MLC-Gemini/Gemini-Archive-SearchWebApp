#./aws/prep_env.sh CRMSD01
dbname=$1

source ./env_def/read_variables.sh $dbname
source ./aws/aws_assume_role.sh $CRMS_PROV_ROLE_ID

#1. Parepare network stack
aws cloudformation deploy --template-file aws/CRMS_CFM/CRMSNetwork.template --stack-name CRMS-NETWORK-$CRMS_DBNAME \
        --parameter-overrides \
        "DBCLASS=$DBCLASS" \
        "VPCID=$VPCID" \
        "Subnet1ID=$SUBNETID1" \
        "Subnet2ID=$SUBNETID2" \
        "Subnet3ID=$SUBNETID3" \
        "Owner=crms" \
        "CostCentre=$T_CostCentre" \
        "SSHAccessRule=$SSHACCESSCIDR" \
        "RDSPort=$DBPORT" \
        "DBSSLPort=$RDS_SSL_PORT" \
        "SSHAccessRuleTibco=$SSHACCESSCIDR_TIBCO" \
        "RDSEngine=$CRMS_RDS_ENGINE" \
--tags \
    "CostCentre=$T_CostCentre" \
    "ApplicationID=$T_ApplicationID" \
    "Environment=$T_Environment" \
    "AppCategory=$T_AppCategory" \
    "SupportGroup=$T_SupportGroup" \
    "Name=$dbname" \
    "PowerMgt=$T_EC2_PowerMgt"  

aws cloudformation wait stack-update-complete --stack-name CRMS-NETWORK-$CRMS_DBNAME
