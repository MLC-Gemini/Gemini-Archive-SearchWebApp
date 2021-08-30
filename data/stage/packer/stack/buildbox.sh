#!/usr/bin/env bash

if [ "$MOCK" == "true" ] ; then
  [ "$mock_found" == "true" ] && return
  case "$ARGS" in
  'curl https://patching-server-hui.ext.national.com.au/images/aws/rhel/7/latest') echo 'ami-111111111111' ;;
  *) return ;;
  esac
  mock_found='true'
  return
fi

[ "$SOURCE_AMI" == "latest" ] && SOURCE_AMI=$(get_latest_hip_ami 'rhel' '7')

validate_vars SOURCE_AMI

instance_type='t3.large'

# Automated tests require parameters and tags to be sorted. To sort them in vim use:
#   SHIFT-V, select the JSON, ! jq -S .

variables() {
  cat <<EOF
{
  "application_id": "$application_id",
  "cost_centre": "$cost_centre",
  "date": "$date",
  "iam_instance_profile": "$iam_instance_profile",
  "image_name": "$image_name",
  "instance_type": "$instance_type",
  "kms_key_alias_name": "$kms_key_alias_name",
  "owner": "$asset_name_uc",
  "source_ami": "$SOURCE_AMI",
  "subnet_id": "$instance_subnet_id",
  "technical_service": "$technical_service"
}
EOF
}
