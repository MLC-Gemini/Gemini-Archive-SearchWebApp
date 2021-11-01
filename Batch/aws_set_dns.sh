#!/usr/bin/bash

env_id=$1
source ./Batch/var/read_variables.sh $env_id
export dns_name=$2
export end_point=$3

echo "5. Create a DNS - keep 1 hour to improve performance"
export dns_action=UPSERT
change_id=$(aws route53 change-resource-record-sets --hosted-zone-id $GEMINI_DNS_ZONE_ID --change-batch "$(envsubst < Batch/template/set_dns.json)" | jq -r ".ChangeInfo.Id")
echo "Wait for change id: $change_id"
aws route53 wait resource-record-sets-changed --id $change_id
