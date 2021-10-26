# destroy_batch_server.sh $env_id

env_id=$1

#Must resume ASG first, otherwise, delete will fail 
aws autoscaling resume-processes --auto-scaling-group-name $(aws cloudformation describe-stacks --stack-name GEMINI-WEB-$env_id | jq -r '.Stacks[].Outputs[]|select (.OutputKey=="AutoScalingGroup").OutputValue')

aws cloudformation delete-stack --stack-name GEMINI-WEB-$env_id-Stack
aws cloudformation wait stack-delete-complete --stack-name GEMINI-WEB-$env_id-Stack
