#_pipeline/create_cloud_watch_ec2.sh CRMSD02
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

aws cloudformation describe-stack-resources --stack-name CRMS-BATCH-$TEST_ENV > tmpBatchStack$$

#parse load balancer and target groups for cloudwatch metrics
load_balancer=$(echo $(cat tmpBatchStack$$ |jq -r '.StackResources[]|select (.LogicalResourceId == "LoadBalancer").PhysicalResourceId') | cut -d'/' -f2-)
aft_target_group=$(echo $(cat tmpBatchStack$$ |jq -r '.StackResources[]|select (.LogicalResourceId == "AFTTargetGroup").PhysicalResourceId')  | cut -d'/' -f2-)
aft_target_group="targetgroup/${aft_target_group}"
ctm_target_group=$(echo $(cat tmpBatchStack$$ |jq -r '.StackResources[]|select (.LogicalResourceId == "CTMTargetGroup").PhysicalResourceId') | cut -d'/' -f2-)
ctm_target_group="targetgroup/${ctm_target_group}"

aws cloudformation deploy --template-file aws/CRMS_CFM/Cloudwatch_EC2.yml --stack-name CRMS-CLOUD-WATCH-EC2-$TEST_ENV --parameter-overrides \
  	"AFTTargetGroup=$aft_target_group" \
  	"AutoScalingGroupName=$(cat tmpBatchStack$$ |jq -r '.StackResources[]|select (.LogicalResourceId == "AutoScalingGroup").PhysicalResourceId')" \
  	"CDTargetGroup=1" \
  	"CTMTargetGroup=$ctm_target_group" \
  	"DashboardName=CLOUD_WATCH-EC2-$TEST_ENV" \
  	"EFSFileSystemID=$(aws cloudformation describe-stacks --stack-name CRMS-EFS-$T_Environment| jq -r '.Stacks[].Outputs[].OutputValue')" \
  	"Environment=$TEST_ENV" \
  	"HIPNotifyHighTopic=$hip_notify_high_topic" \
  	"HIPNotifyLowTopic=$hip_notify_low_topic" \
  	"HIPNotifyMediumTopic=$hip_notify_medium_topic" \
  	"LoadBalancer=$load_balancer" \
  	"S3BucketName=crms${T_Environment,,}-crms-s3elb${TEST_ENV,,}" \
    "CRMSSupport"=$support_topic_arn \
        --tags \
        "CostCentre=$T_CostCentre" \
        "ApplicationID=$T_ApplicationID" \
        "Environment=$T_Environment" \
        "AppCategory=$T_AppCategory" \
        "SupportGroup=$T_SupportGroup" \
        "Name=$dbname" \
        "PowerMgt=$T_EC2_PowerMgt"

rm tmpBatchStack$$
