#_pipeline/deploy_dev_linux.sh UserName
env_id=CRMS-build
user_name=$1

echo "0. Get environment variable"
source ./env_def/read_variables.sh $env_id

INSTANCE_ID=`\
aws ec2 run-instances \
    --subnet-id $SUBNETID1 \
    --security-group-ids $SECURITY_GRP_TOOLING \
    --image-id $(./aws/aws_get_parameter.sh $AWS_PAR_BATCH_IMAGE) \
    --instance-type $INSTANCE_TYPE_BATCH \
    --key-name "$KEYPAIR_NAME" \
    --iam-instance-profile Name=$IAM_PROFILE_PROV \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=ApplicationID,Value=ML0056},{Key=CostCentre,Value=V_CRMS},{Key=TechnicalService,Value=CRMS},{Key=Owner,Value=CRMS},{Key=Environment,Value=DEV},{Key=Account,Value=CRMS},{Key=Name,Value=CRMS-DEV-Linux-'$user_name-$(date +%Y-%m-%d-%H-%M-%S)'}]' \
    | jq ".Instances[0]|.InstanceId"|sed "s/\"//g"`
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=CostCentre,Value=$T_CostCentre Key=ApplicationID,Value=$T_ApplicationID Key=Environment,Value=$T_Environment Key=AppCategory,Value=$T_AppCategory Key=SupportGroup,Value=$T_SupportGroup Key=Name,Value=Linux-Dev-$user_name-$(date +%Y-%m-%d-%H-%M-%S) Key=PowerMgt,Value=$T_EC2_PowerMgt Key=BackupOptOut,Value=$T_BackupOptOut

echo "- Wait for instance status OK"
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

# ./aws/aws_set_dns.sh $env_id ${user_name}_dev_l.${CRMS_DNS_ZONE_NAME} $(aws ec2 describe-instances --instance-id $INSTANCE_ID|jq -r '.Reservations[0].Instances[0].PrivateIpAddress')

aws ec2 describe-instances --instance-id $INSTANCE_ID|jq -r ".Reservations[0].Instances[0].PrivateIpAddress"
