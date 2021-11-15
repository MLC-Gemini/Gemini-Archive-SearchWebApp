#!/usr/bin/bash

env_id=$1
source ./Batch/var/read_variables.sh $env_id

hip_notify_low_topic=$(aws sns create-topic --name HIPNotifyGeminiLowTopic|jq -r '.TopicArn')
hip_notify_medium_topic=$(aws sns create-topic --name HIPNotifyGeminiMediumTopic|jq -r '.TopicArn')
hip_notify_high_topic=$(aws sns create-topic --name HIPNotifyGeminiHighTopic|jq -r '.TopicArn')
support_topic_arn=$(aws sns create-topic --name GEMININotifyTopic|jq -r '.TopicArn')

IFS=',';read -ra email_address <<< "$Gemini_SUPPORT_EMAIL"
for i in "${email_address[@]}"
do
        aws sns subscribe --topic-arn "$hip_notify_low_topic" --protocol email --notification-endpoint "$i"
        aws sns subscribe --topic-arn "$hip_notify_medium_topic" --protocol email --notification-endpoint "$i"
        aws sns subscribe --topic-arn "$hip_notify_high_topic" --protocol email --notification-endpoint "$i"
done

aws cloudformation describe-stack-resources --stack-name GEMINI-WEB-$T_Environment-Stack > tmpBatchStack$$
load_balancer=$(echo $(cat tmpBatchStack$$ |jq -r '.StackResources[]|select (.LogicalResourceId == "LoadBalancer").PhysicalResourceId') | cut -d'/' -f2-)

aws cloudformation deploy --template-file Batch/template/Cloudwatch_EC2.yml --stack-name Gemini-CLOUD-WATCH-EC2-$T_Environment --parameter-overrides \
    "AutoScalingGroupName=$(cat tmpBatchStack$$ |jq -r '.StackResources[]|select (.LogicalResourceId == "AutoScalingGroup").PhysicalResourceId')" \
    "DashboardName=CLOUD_WATCH-EC2-$TEST_ENV" \
    "Environment=$T_Environment" \
    "HIPNotifyHighTopic=$hip_notify_high_topic" \
    "HIPNotifyLowTopic=$hip_notify_low_topic" \
    "HIPNotifyMediumTopic=$hip_notify_medium_topic" \
    "LoadBalancer=$load_balancer" \
    "GeminiSupport"=$support_topic_arn \
        --tags \
        "CostCentre=$T_CostCentre" \
        "ApplicationID=$T_ApplicationID" \
        "Environment=$T_Environment" \
        "AppCategory=$T_AppCategory" \
        "SupportGroup=$T_SupportGroup" \
        "PowerMgt=$T_EC2_PowerMgt"

rm tmpBatchStack$$
