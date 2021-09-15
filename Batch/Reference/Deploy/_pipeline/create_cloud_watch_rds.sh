#_pipeline/create_cloud_watch_rds.sh CRMSD02
dbname=CRMSD02

dbname=$1
source ./env_def/read_variables.sh $dbname

hip_notify_low_topic=$(aws sns create-topic --name HIPNotifyCRMSLowTopic|jq -r '.TopicArn')
hip_notify_medium_topic=$(aws sns create-topic --name HIPNotifyCRMSMediumTopic|jq -r '.TopicArn')
hip_notify_high_topic=$(aws sns create-topic --name HIPNotifyCRMSHighTopic|jq -r '.TopicArn')
support_topic_arn=$(aws sns create-topic --name SNS_Support_$T_Environment | jq -r '.TopicArn')

IFS=',';read -ra email_address <<< "$CRMS_SUPPORT_EMAIL"
for i in "${email_address[@]}"
do
       	aws sns subscribe --topic-arn "$hip_notify_low_topic" --protocol email --notification-endpoint "$i"
       	aws sns subscribe --topic-arn "$hip_notify_medium_topic" --protocol email --notification-endpoint "$i"
       	aws sns subscribe --topic-arn "$hip_notify_high_topic" --protocol email --notification-endpoint "$i"
done

aws cloudformation deploy --template-file aws/CRMS_CFM/Cloudwatch_RDS.yml --stack-name CRMS-CLOUD-WATCH-$dbname --parameter-overrides \
        "Application=$dbname" \
        "DBName=${dbname,,}" \
        "DashboardName=CLOUD-WATCH-$dbname" \
        "Environment=$T_Environment" \
        "HIPNotifyHighTopic=$hip_notify_high_topic" \
        "HIPNotifyLowTopic=$hip_notify_low_topic" \
        "HIPNotifyMediumTopic=$hip_notify_medium_topic" \
        "CRMSSupport"=$support_topic_arn \
        --tags \
                "CostCentre=$T_CostCentre" \
                "ApplicationID=$T_ApplicationID" \
                "Environment=$T_Environment" \
                "AppCategory=$T_AppCategory" \
                "SupportGroup=$T_SupportGroup" \
                "Name=$dbname" \
                "PowerMgt=$T_EC2_PowerMgt"
