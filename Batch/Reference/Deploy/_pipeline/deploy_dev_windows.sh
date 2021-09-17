#_pipeline/deploy_dev_windows.sh UserName
#Run instance using latest Robot Server image
env_id=CRMS-build
machine_name=CRMSWIDA$1
join_domain=$2


echo "0. Get environment variable"
source ./aws/aws_get_kms_ec2_keyid.sh $env_id
source ./env_def/read_variables.sh DEVOPS SELECT "AWS_PAR_ROBOT_IMAGE"

ami_id=$(./aws/aws_get_parameter.sh $AWS_PAR_ROBOT_IMAGE)
aws ec2 describe-images --image-id $ami_id|jq -r '.Images[].BlockDeviceMappings|del(.[]|select (.Ebs == null))|del(.[].Ebs.SnapshotId)|.[].Ebs.Encrypted=true|.[].Ebs.KmsKeyId="'$Kms_Ec2_Keyid'"' > encrypted_device_mapping_$$.json

if [[ "$join_domain" == "Y" ]];
then
userdata="<powershell>
Set-ItemProperty -Path \"HKLM:\\Software\\HIP\\\" -Name 'Environment' -Value \"$CRMS_DOMAIN\"
Set-ItemProperty -Path \"HKLM:\\Software\\HIP\\\" -Name 'DJOU' -Value 'crms'
Rename-Computer -NewName \"$machine_name\" -Force -PassThru -Restart
</powershell>
"
fi

INSTANCE_ID=`\
aws ec2 run-instances \
    --block-device-mappings file://encrypted_device_mapping_$$.json \
    --subnet-id $SUBNETID1 \
    --security-group-ids $SECURITY_GRP_TOOLING \
    --image-id $ami_id \
    --instance-type $INSTANCE_TYPE_WIN_DEV \
    --key-name "$KEYPAIR_NAME" \
    --iam-instance-profile Name=$IAM_PROFILE_PROV \
    --user-data "$userdata" \
    --tag-specifications \
	"ResourceType=instance,
	Tags=[	
		{Key=CostCentre,Value=$T_CostCentre},
		{Key=ApplicationID,Value=$T_ApplicationID},
		{Key=Environment,Value=$T_Environment},
		{Key=AppCategory,Value=$T_AppCategory},
		{Key=SupportGroup,Value=$T_SupportGroup},
		{Key=PowerMgt,Value=$T_EC2_PowerMgt},
		{Key=BackupOptOut,Value=$T_BackupOptOut},
		{Key=TechnicalService,Value=CRMS},
		{Key=Owner,Value=CRMS},
		{Key=Account,Value=CRMS},
		{Key=Name,Value=$machine_name}
	]" \
    | jq ".Instances[0]|.InstanceId"|sed "s/\"//g"`

echo "- Wait for instance status OK"
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
rm -f encrypted_device_mapping_$$.json

aws ec2 describe-instances --instance-id $INSTANCE_ID|jq -r ".Reservations[0].Instances[0].PrivateIpAddress"