#!/usr/bin/bash
#./aws/aws_send_message.sh "[Message]"
sns_message=$1

# get/create sns topic for SNS Jenkins Topic
# 
# Note: 
#   1. cannot necessarily get Environment passed through for every jenkins job, so sending a message to a Jenkins-specific notify topic.
#   2. this topic must already exist, with subscriptions to be effective
#   3. always pass through the Build URL, so there is a link to the actual environment the job was run in. (see Jenkinsfile jobs)
support_topic_arn=$(aws sns create-topic --name SNS_Jenkins | jq -r '.TopicArn')

#publish message to SNS Topic
aws sns publish --topic-arn $support_topic_arn --message "'$sns_message'"