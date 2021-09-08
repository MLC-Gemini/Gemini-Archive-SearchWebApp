#source aws/aws_get_kms_ec2_keyid.sh CRMST03
env_id=$1
source ./env_def/read_variables.sh $env_id

Kms_Ec2_Keyid=$(./aws/aws_get_parameter.sh $KMS_EC2)
if [[ $Kms_Ec2_Keyid == 'null' ]]; then
        envsubst < aws/CRMS_CFM/template/kms_policy_ami_template.json > kms_policy_ami_$$.json
        Kms_Ec2_Keyid=$(aws kms create-key --policy file://kms_policy_ami_$$.json|jq -r '.KeyMetadata.KeyId')
        #CAST requirement to enable key rotation
        aws kms enable-key-rotation --key-id $(echo $Kms_Ec2_Keyid|sed 's/^.*\///')
        ./aws/aws_put_parameter.sh $KMS_EC2 $Kms_Ec2_Keyid
	rm kms_policy_ami_$$.json
fi
export Kms_Ec2_Keyid
