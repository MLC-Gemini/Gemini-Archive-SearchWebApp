#Find all image registration IDs in all environments
image_reg_ids=$( \
	find env_def -name "*.cfg" -exec \
		grep -E "AWS_PAR_ROBOT_IMAGE|AWS_PAR_BATCH_IMAGE|AWS_PAR_ROBOT_IMAGE_PROM" {} \; \
		|sed 's/^.*=//' \
		|sort -u)

#all images for the current account minus all referenced images
images_to_deleted=$(comm -23 \
	<(aws ec2 describe-images --owners $(aws sts get-caller-identity | jq -r '.Account')|jq -r '.Images[].ImageId'|sort -u) \
	<(for i in $image_reg_ids;do aws/aws_get_parameter.sh "$(echo $i|sed 's/^.*=//')"; done | sort -u) \
)

#all images currently is used by instances
images_to_deleted=$(comm -23 \
	<(echo $images_to_deleted|sed "s/ /\n/g") \
	<(aws ec2 describe-instances | jq -r '.Reservations[].Instances[].ImageId' | sort -u)
)

aws ec2 describe-images --image-id $images_to_deleted|jq -r '.Images[].Name'|sort

echo "Please verify all above images will be deleted, please verify: (y/n)?"
read v_reply
if [ "$v_reply" == "y" ]; then
	for i in $images_to_deleted 
	do
		aws ec2 deregister-image --image-id $i
	done
fi
