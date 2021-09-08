#./_pipeline/deploy_robot_server.sh CRMSD01
#1. Set environment
dbname=$1

#2. Read environment variables and assume provision role
source aws/checkout_stable_release.sh $dbname
source ./aws/aws_assume_role.sh $CRMS_PROV_ROLE_ID

#3. If DNS is not used, use IP address retrieved from RDS
if [[ $CRMS_RDS_DNS != '' ]]; then
	export CRMS_IP=$CRMS_RDS_DNS.crms.awsnp.national.com.au
else
	export CRMS_IP=$(aws/aws_get_db_end_point.sh $CRMS_DBNAME Address)
fi

#4. Get the latest baked image from SSM store
ami_id=`./aws/aws_get_parameter.sh $AWS_PAR_ROBOT_IMAGE`

#5. Prepare Powershel deploy script with environment variable resolved
USERDATA=$(echo "<powershell>
new-psdrive -Name 'par' -PSProvider Variable -Root 'c:\tmp'
#1. Inject environment variables
$(./env_def/read_ps_variables.sh powershell/robot_deploy.ps1)
#2. Deploy environment
powershell c:\\tmp\\robot_deploy.ps1
#3. Start CRMS Service
new-service -name \"CRMS Robots Manager\" -BinaryPathName \"C:\\tmp\\CRMSServiceApp.exe \"\"User Id=crms;Password=$CRMS_PWD;Data Source=$CRMS_DBNAME\"\"\" -StartupType Automatic 
#4. Join Domain
Set-ItemProperty -Path \"HKLM:\\Software\\HIP\\\" -Name 'Environment' -Value \"$CRMS_DOMAIN\"
Set-ItemProperty -Path \"HKLM:\\Software\\HIP\\\" -Name 'DJOU' -Value 'crms'
Rename-Computer -NewName \"$CRMS_ROBOT_NAME\" -Force -PassThru -Restart
</powershell>" |openssl base64 -A)

#5. Deploy stack
aws cloudformation deploy \
--template-file aws/CRMS_CFM/AutoScaling.json \
--stack-name CRMS-ROBOT-$CRMS_DBNAME \
--parameter-overrides \
"ComputerName=$CRMS_ROBOT_NAME" \
"AMIID=$ami_id" \
"KeyName=$KEYPAIR_NAME" \
"InstanceType=$INSTANCETYPE_ROBOT" \
"IAMProfile=$IAM_PROFILE_INST" \
"NetworkStackName=CRMS-NETWORK-$CRMS_DBNAME" \
"BootPSScript=$USERDATA" \
--tags \
    "CostCentre=$T_CostCentre" \
    "ApplicationID=$T_ApplicationID" \
    "Environment=$T_Environment" \
    "AppCategory=$T_AppCategory" \
    "SupportGroup=$T_SupportGroup" \
    "PowerMgt=$T_EC2_PowerMgt"

#6. Refresh running EC2 by terminating it(ASG will start a new instance)
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Name,Values=$CRMS_ROBOT_NAME" "Name=instance-state-code,Values=16" | jq -r '.Reservations[]|.Instances[]|.InstanceId')

rm -rf $Git_Working_Folder