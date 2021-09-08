#./promote_crms_specific.sh CRMS-build DC_Exit CRMSD03 Y
#1. Run a windows instance in provision VPC (CRMS-build)
#2. Which release
#3. Which database
#4. Keep instance alive

trap "kill $child_pid" SIGTERM

cleanup() {
	source ./env_def/read_variables.sh $env_id

	#Force shutdown the machine
	if [ "$keep_alive" == "Y" ]; then
		destroy_instance='N'
	else
		if [ "$keep_alive" == "S" ]; then
			destroy_instance='S'
		else
			destroy_instance='Y'
		fi
	fi

	if [ "$destroy_instance" == "Y" ]; then
		if [[ $instance_id != 'NA' && $instance_id != null ]]; then
			./aws/aws_put_parameter.sh ${CRMS_WIN_PROV_BOX}_id 'NA'
			aws ec2 terminate-instances --instance-ids $instance_id
			aws ec2 wait instance-terminated --instance-ids $instance_id
		fi
		aws ec2 delete-key-pair --key-name "tmpkey-Promotion-$env_id-$$" 2>/dev/null
		rm -f tmp_bake_robot_$env_id-$$.pem
		rm -f tmp_robot_bake_prep-$$.ps1
	else
		if [ "$destroy_instance" == "S" ]; then
			aws ec2 stop-instances --instance-ids $instance_id
		fi
		if [ $creating_new_instance == 'Y' ]; then
			./aws/aws_put_parameter.sh ${CRMS_WIN_PROV_BOX}_id $instance_id
			./aws/aws_put_parameter.sh ${CRMS_WIN_PROV_BOX}_ip $ip
			./aws/aws_put_parameter.sh ${CRMS_WIN_PROV_BOX}_pwd $pwd
		fi
		#aws ec2 stop-instances --instance-ids $instance_id

	fi
	rm -f crms_specific_promotion$$.ps1
	rm -rf $release_folder
}
trap cleanup EXIT

#Sample variables, they are overwritten by the actual parameters
env_id=CRMS-build
release_id=DC_Exit
dbname=CRMSD04
keep_alive=Y

#Pass variables
env_id=$1
release_id=$2
dbname=$3
keep_alive=$4

#Get previous instance details for the build environment
source ./env_def/read_variables.sh $env_id

#Pull release staging folder
release_folder=/tmp/release/$$
aws/checkout_release.sh $RELEASE_STAGING_URL $release_id $release_folder

instance_id=$(./aws/aws_get_parameter.sh ${CRMS_WIN_PROV_BOX}_id)
ip=$(./aws/aws_get_parameter.sh ${CRMS_WIN_PROV_BOX}_ip)
pwd=$(./aws/aws_get_parameter.sh ${CRMS_WIN_PROV_BOX}_pwd)
crms_tmp_sec_group_id=$(./aws/aws_get_parameter.sh ${CRMS_WIN_PROV_BOX}_secgrp)

#Release folder structure:
#ID --> dll
#       --> reg_required
#           -- *.*
#       --> reg_not_required
#           -- *.*
#   --> process
#       -- *.xml
#   --> sql
#       -- schema.sql
#       -- procs.sql
#       -- sql_update.sql

# "1. Create CRMS Robot Server in Provision VPC with ProvisionProfile as Promotion Agent"
# "2. Send promotion code(ProcessCopy.xml, dlls etc) to Promotion Agent"
# "3. Run Linux powershell to trigger promotion process"
# "4. Review promotion result"

#Have we created new instance?
creating_new_instance='N'
#Check whether CRMS Promotion agent is already created

if [[ "$instance_id" == "NA" || "$instance_id" == "null" ]]; then
	creating_new_instance='Y'
else
	instance_status=$(aws ec2 describe-instance-status --instance-id $instance_id|jq -r '.InstanceStatuses[0].InstanceStatus.Details[0].Status')
	if [ "$instance_status" != "passed" ]; then
		tmp_s=$(aws ec2 describe-instances --instance-id $instance_id|jq -r '.Reservations[0].Instances[0].State.Name')
		if [ "$tmp_s" == "stopped" ]; then
			aws ec2 start-instances --instance-ids $instance_id
			aws ec2 wait instance-running --instance-ids $instance_id
		else
			if [ "$tmp_s" == "stopping" ]; then
				aws ec2 wait instance-stopped --instance-ids $instance_id
				aws ec2 start-instances --instance-ids $instance_id
				aws ec2 wait instance-running --instance-ids $instance_id				
			else
				creating_new_instance='Y'
			fi
		fi
	fi
fi

if [ "$creating_new_instance" == "Y" ]; then
	echo "Creating promotion instance..."
	#cleanup 'N'
	
	#Run Promotion EC2 instance in Build environment
	source ./env_def/read_variables.sh $env_id

	#Use the latest AMI for promotion
	ami_id=$(./aws/aws_get_parameter.sh $AWS_PAR_ROBOT_IMAGE_PROM)
  if [ "$(aws ec2 describe-images --image-id $ami_id 2>/dev/null |jq -r '.Images[0].ImageId')" != "$ami_id" ]; then
     echo "Promotion box ami does not exist, please re-bake using ./_pipeline/bake_ec2_windows"
     exit 1
  fi

	#Create security Group
	if [ "$crms_tmp_sec_group_id" == "null" ]; then
		crms_tmp_sec_group_id=$(aws ec2 create-security-group --group-name "tmpBAKE-Promotion-$env_id" --description "CRMS-BAKE-Promotion-$env" --vpc-id $VPCID|jq -r ".GroupId")
		aws ec2 authorize-security-group-ingress --group-id $crms_tmp_sec_group_id --ip-permissions IpProtocol=tcp,FromPort=5985,ToPort=5986,IpRanges="[{CidrIp=$SSHACCESSCIDR,Description=\"WinRM for baking\"}]"
		./aws/aws_put_parameter.sh ${CRMS_WIN_PROV_BOX}_secgrp $crms_tmp_sec_group_id
	fi
	aws ec2 create-key-pair --key-name "tmpkey-Promotion-$env_id-$$" --query 'KeyMaterial' --output text > tmp_bake_robot_$env_id-$$.pem
	chmod g-rw tmp_bake_robot_$env_id-$$.pem
	chmod o-rw tmp_bake_robot_$env_id-$$.pem

	#Prepare userdata for the promotion instance (Enable windows RM only)
	echo "<powershell>
	#1. Enable WinRM
	Set-Item WSMan:\\localhost\\Client\\TrustedHosts -Force -Value *
	New-NetFirewallRule -Name 'WinRM HTTPS' -DisplayName 'WinRM HTTPS' -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
	\$thumbprint = (New-SelfSignedCertificate -DnsName 'BAKE' -CertStoreLocation Cert:\\LocalMachine\\My).Thumbprint
	cmd.exe /C \"winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=\"\"BAKE\"\"; CertificateThumbprint=\"\"\$thumbprint\"\"}\"
	</powershell>" > tmp_robot_bake_prep-$$.ps1
	unix2dos tmp_robot_bake_prep-$$.ps1

	instance_id=$(\
	aws ec2 run-instances \
    	--subnet-id $SUBNETID1 \
    	--security-group-ids $crms_tmp_sec_group_id \
    	--image-id $ami_id \
    	--instance-type t3.medium \
    	--key-name "tmpkey-Promotion-$env_id-$$" \
    	--iam-instance-profile Name=$IAM_PROFILE_PROV \
    	--user-data file://tmp_robot_bake_prep-$$.ps1 \
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
                	{Key=Name,Value=CRMSWIDA9999}
        	]" \
    	| jq -r ".Instances[0]|.InstanceId")
	
	echo "- Wait for instance status OK and Password Ready"
	aws ec2 wait instance-status-ok --instance-ids $instance_id
	aws ec2 wait password-data-available --instance-id $instance_id
	
	echo "- Get windows password" and wait for the installation to complete
	pwd=$(aws ec2 get-password-data --instance-id $instance_id --priv-launch-key tmp_bake_robot_$env_id-$$.pem | jq -r .PasswordData)
	ip=$(aws ec2 describe-instances --instance-id $instance_id | jq -r ".Reservations|.[0]|.Instances|.[0]|.PrivateDnsName")
	echo $ip $pwd
else
	echo "Use existing instance: $instance_id"
	#aws ec2 start-instances --instance-ids $instance_id
fi

#Start release process for the database
source ./env_def/read_variables.sh $dbname

#Create robot deploy SNS topic and add subscribers
export SNS_ROBOT_TOPIC_ARN=$(aws sns create-topic --name SNS_Robot_$dbname | jq -r '.TopicArn')
IFS=',';read -ra email_address <<< "$CRMS_SUPPORT_EMAIL"
for i in "${email_address[@]}"
do
	#Don't send notification repeatitively
	if [ ! "$i" == "$(aws sns list-subscriptions-by-topic --topic-arn $SNS_ROBOT_TOPIC_ARN|jq -r '.Subscriptions[]|select (.Endpoint=="'$i'").Endpoint')" ]; then
		aws sns subscribe --topic-arn "$SNS_ROBOT_TOPIC_ARN" --protocol email --notification-endpoint "$i"
	fi
done

#If No database DNS is configured, use IP
if [[ $CRMS_RDS_DNS != '' ]]; then
	export CRMS_IP=$CRMS_RDS_DNS.$CRMS_DNS_ZONE_NAME
else
	export CRMS_IP=$(aws/aws_get_db_end_point.sh $CRMS_DBNAME Address)
fi

#Get build box details and pass them to powershell script for scp release details to promotion box
export build_box_ip=$(hostname -i|awk '{print $1}')
export build_box_art_folder=${release_folder}/release/${release_id}
export release_id


#Prepare powershell script
echo "new-psdrive -Name 'par' -PSProvider Variable -Root 'c:\tmp'" > crms_specific_promotion$$.ps1
echo "set-content -Path C:\app\WealthTNSNames\tnsnames.ora (get-content -Path C:\app\WealthTNSNames\tnsnames.ora | Select-String -Pattern \"$CRMS_DBNAME\" -NotMatch)" >> crms_specific_promotion$$.ps1
echo "Add-Content C:\app\WealthTNSNames\tnsnames.ora \"$CRMS_DBNAME.world=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCPS)(HOST=$CRMS_RDS_DNS.$CRMS_DNS_ZONE_NAME)(PORT=$RDS_SSL_PORT)))(CONNECT_DATA=(SID=$CRMS_DBNAME)))\"" >> crms_specific_promotion$$.ps1
./env_def/read_ps_variables.sh powershell/promote_crms_specific_remote.ps1 >> crms_specific_promotion$$.ps1
cat powershell/promote_crms_specific_remote.ps1 >> crms_specific_promotion$$.ps1

rm -f /tmp/promotion_result_$release_id
powershell/run_ps_remote.ps1 $dbname "administrator" $ip $pwd crms_specific_promotion$$.ps1 &
child_pid=$!
wait $child_pid
cat /tmp/promotion_result_$release_id
