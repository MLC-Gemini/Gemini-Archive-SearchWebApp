#./pipeline/create_s3_elb.sh CRMST01
cleanup() {
	rm -f tmp_s3_elb_$$.jsom
}
trap cleanup EXIT


envid=CRMST01
envid=$1
source env_def/read_variables.sh $envid
export s3_bucket_name="crms${T_Environment,,}-crms-s3elb${TEST_ENV,,}"
export kms_ec2_keyid=$(./aws/aws_get_parameter.sh $KMS_EC2)
export Iam_profile_prov=$(aws iam get-role --role-name $IAM_PROFILE_PROV|jq -r '.Role.RoleId')
export Iam_profile_inst=$(aws iam get-role --role-name $IAM_PROFILE_INST|jq -r '.Role.RoleId')
export S3_allow_devops=$(aws iam get-role --role-name $S3_ALLOW_DEVOPS|jq -r '.Role.RoleId')

envsubst < aws/CRMS_CFM/template/s3_elb_template.json > tmp_s3_elb_$$.jsom
aws cloudformation deploy --template-file tmp_s3_elb_$$.jsom --stack-name ${TEST_ENV}-CRMS-ELB-S3Bucket-Stack \
        --tags \
                "CostCentre=$T_CostCentre" \
                "ApplicationID=$T_ApplicationID" \
                "Environment=$T_Environment" \
                "AppCategory=$T_AppCategory" \
                "SupportGroup=$T_SupportGroup" \
                "PowerMgt=$T_EC2_PowerMgt"
