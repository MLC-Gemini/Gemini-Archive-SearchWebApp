#!/usr/bin/env bash

if [ "$MOCK" == "true" ] ; then
  case "$ARGS" in
    "curl --silent $meta_data/network/interfaces/macs/") echo '00:11:22:aa:bb:cc' ;;
    "curl --silent $meta_data/network/interfaces/macs/$mac/subnet-id") echo 'subnet-111111111111111111' ;;
    "curl --silent $meta_data/network/interfaces/macs/$mac/security-group-ids") echo 'sg-111111111111111111' ;;
    'aws ssm get-parameter --name /gemini/artifactory_api_key --with-decryption --query Parameter.Value --output text') echo 'myartifactorykey' ;;
    *) return ;;
  esac
  mock_found='true'
  return
fi

valid_ami_stacks='batch|buildbox|jenkins' # stacks with pre-baked AMIs.
valid_stacks='batch|batch_efs|fileserver|cw|kms|s3|buildbox|jenkins' # all stacks.
valid_envgroups='nonprod|prod'
valid_nonprods='dev|sit'
valid_prods='prod'
valid_environments='dev|prod|sit' # always use ENVGROUP == prod for prod environment.
valid_stages='packer|cloudformation'

PATH="/usr/local/bin:$PATH"
AWS_DEFAULT_REGION='ap-southeast-2'
export PATH AWS_DEFAULT_REGION

asset_name_lc='gemini'
asset_name_uc='GEMINI'
asset_name_short_lc='gem'
host_name_assetname="$asset_name_short_lc"

application_id='ML0095'
app_category='B'
support_group='WorkManagementProductionSupport'

tag_power_mgt="MBH"
tag_backup_optout="Yes"
tag_app_category='B'

envgroup_first_uc=$(sed -E 's/(.)/\u\1/' <<< "$ENVGROUP")
environment_first_uc=$(sed -E 's/(.)/\u\1/' <<< "$ENVIRONMENT")
#instance_type='t2.large'

meta_data="http://169.254.169.254/latest/meta-data"
mac=$(curl --silent "$meta_data/network/interfaces/macs/")
instance_subnet_id=$(curl --silent "$meta_data/network/interfaces/macs/$mac/subnet-id")
instance_security_group_ids=$(curl --silent "$meta_data/network/interfaces/macs/$mac/security-group-ids")

remote_access_cidr='10.0.0.0/8'

cost_centre='V_Gemini'

kms_key_policy_id="/$asset_name_lc"
kms_key_alias_name="alias/$asset_name_lc"
kms_stack_name="${asset_name_uc}KMSStack"
export_name="$asset_name_lc"

#kms_key_policy_id='/geminiprod'
#kms_key_alias_name='alias/geminiprod'
#kms_stack_name='GEMINIKMSStack'
#export_name='gemini'

stack_lc=$STACK
stack_uc=$(sed 's/.*/\U&/' <<< "$STACK")

technical_service="$stack_uc"
key_pair_name="${asset_name_uc}${stack_uc}${envgroup_first_uc}"

s3_bucket_name="$asset_name_lc-$ENVGROUP-3118" # 3118 a random string to ensure global uniqueness.
s3_log_bucket_name="$asset_name_lc-$ENVGROUP-3867"

#host_name_assetname='GEMI'

#dns_update_role='arn:aws:iam::803264201466:role/HIPExtNpRoute53UpdateRole8'
#dns_update_role='arn:aws:iam::522412867873:role/HIPExtRoute53UpdateRole4'
#iam_prod_account_arn='arn:aws:iam::937709052626:root'

performance_mode='generalPurpose' # can also be set to maxIO
throughput_mode='bursting' # can also be set to provisioned additional paramater ProvisionedThroughputInMibps optional in CF# RDS stack.

#engine_version='14.00.3035.2.v1'
#allocated_storage='50'
#db_instance_class='db.m5.large'
#multi_az='true'
#storage_type='gp2'
#backup_retention_period='1'
#preferred_backup_window='11:00-11:30'
#preferred_maintenance_window='Sat:17:00-Sat:18:00'
#db_snapshot='NOTREADY' # FIXME.

date=$(date +%Y%m%d%H%M%S)
image_name="$asset_name_uc-$stack_uc"
#artifactory='https://artifactory.ext.national.com.au'
#repo='MLCDEVOPS-build'
#artifactory_api_key=$(ssm_get '/gemini/artifactory_api_key') || exit $?

iam_prod_account_arn='arn:aws:iam::937709052626:root'
