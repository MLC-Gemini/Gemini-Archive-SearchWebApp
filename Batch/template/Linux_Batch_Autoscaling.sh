echo '#!/bin/bash' > tmp_batch_userdata_$$

env_id="nonprod"
source ./Batch/var/read_variables.sh $env_id
#echo "mv /etc/ssh/ssh_host_ecdsa_key_AFT /etc/ssh/ssh_host_ecdsa_key" >> tmp_batch_userdata_$$
#echo "mv /etc/ssh/ssh_host_ecdsa_key_AFT.pub /etc/ssh/ssh_host_ecdsa_key.pub" >> tmp_batch_userdata_$$

#echo 'echo $(cat /tmp/mount-targets.lst| jq -r ''.MountTargets[]|select (.SubnetId=="''$(aws ec2 describe-instances --instance-ids $(curl http://169.254.169.254/latest/meta-data/instance-id) | jq -r ".Reservations[0].Instances[0].SubnetId")''").IpAddress'')  $efsid.efs.ap-southeast-2.amazonaws.com >> /etc/hosts' >> tmp_batch_userdata_$$


# Launch config/app server does not have permission to do this
##Update DNS Name for SMB Server - todo
#echo 'aws route53 change-resource-record-sets --hosted-zone-id '$CRMS_DNS_ZONE_ID' --change-batch ''
# { "Changes":
#        [
#
#                {       "Action": "UPSERT",
#                        "ResourceRecordSet": {
#                                "Name": "'$BATCH_DNS.$CRMS_DNS_ZONE_NAME'",
#                                "Type": "CNAME",
#                                "TTL": 3600,
#                                "ResourceRecords": [
#                                        { "Value": "$(hostname -i)"}
#                                ]
#                        }
#                }
#        ]
#}
#' >> tmp_batch_userdata_$$

#set smb password
#echo "/usr/bin/bash /tmp/defered_action.sh" >> tmp_batch_userdata_$$

#Apply patch in background when autoscaling kicks in
echo "echo 'curl https://hip.ext.national.com.au/hip_upgrade.sh | bash -s -- -a latest' > /tmp/patch-me.sh" >> tmp_batch_userdata_$$
echo "nohup sudo /usr/bin/bash /tmp/patch-me.sh &" >> tmp_batch_userdata_$$

source ./aws/aws_assume_role.sh "$CRMS_PROV_ROLE_ID"
aws cloudformation deploy \
        --template-file Batch/template/Linux_Batch_Autoscaling.yml \
        --stack-name CRMS-BATCH-$TEST_ENV \
        --parameter-overrides \
                "NotifyTopic=$hip_topic_arn" \
                "CTMAgentToServerPort=$CTM_AGENT_TO_SERVER_PORT" \
                "CTMServerToAgentPort=$CTM_SERVER_TO_AGENT_PORT" \
                "IAMInstanceProfile=$IAM_PROFILE_INST" \
                "ImageId=$(./aws/aws_get_parameter.sh Deploy-$AWS_PAR_BATCH_IMAGE)" \
                "InstanceType=$INSTANCE_TYPE_BATCH" \
                "KeyPairName=$KEYPAIR_NAME" \
                "RemoteAccessCIDR=$SSHACCESSCIDR" \
                Subnets="$SUBNETID1,$SUBNETID2,$SUBNETID3" \
                "VpcId=$VPCID" \
                "ApplicationID=$T_ApplicationID" \
                "Owner=CRMS" \
                "UserData1=$(cat tmp_batch_userdata_$$|openssl base64 -A)" \
        --tags \
                "CostCentre=$T_CostCentre" \
                "Name=crms-$T_Environment-batch" \
                "Environment=$T_Environment" \
                "AppCategory=$T_AppCategory" \
                "SupportGroup=$T_SupportGroup" \
                "PowerMgt=$T_EC2_PowerMgt"
cat tmp_batch_userdata_$$
rm tmp_batch_userdata_$$

#restart all EC2 by killing them.
#asg_group_name=$(aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV| jq -r '.StackResources[]|select (.LogicalResourceId=="AutoScalingGroup").PhysicalResourceId'|sed 's/ /,/g')
#instances=$(aws autoscaling describe-auto-scaling-instances | jq -r '.AutoScalingInstances[]|select (.AutoScalingGroupName=="'$asg_group_name'").InstanceId'|paste -sd " " -)
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --instance-id  \
                $(aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-names  \
                        $(aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV \
                        |jq -r '.StackResources[]|select (.ResourceType=="AWS::AutoScaling::AutoScalingGroup").PhysicalResourceId')  \
                |jq -r '.AutoScalingGroups[0].Instances[].InstanceId') \
        |jq -r '.Reservations[].Instances[].InstanceId')

