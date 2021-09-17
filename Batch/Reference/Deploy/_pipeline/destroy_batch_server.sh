#_pipeline/destroy_batch_server.sh $test_env
test_env=$1

#Must resume ASG first, otherwise, delete will fail 
aws autoscaling resume-processes --auto-scaling-group-name $(aws cloudformation describe-stacks --stack-name CRMS-BATCH-$test_env | jq -r '.Stacks[].Outputs[]|select (.OutputKey=="AutoScalingGroup").OutputValue')

aws cloudformation delete-stack --stack-name CRMS-BATCH-$test_env
aws cloudformation wait stack-delete-complete --stack-name CRMS-BATCH-$test_env
