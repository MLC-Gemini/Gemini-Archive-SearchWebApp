#!/usr/bin/bash
#./aws/aws_set_dns.sh CRMSD02 "bat.dev.crms.awsnp.national.com.au" "CRMS-BATCH-DEV-LoadBalancer-473b16a0bde17d88.elb.ap-southeast-2.amazonaws.com"
envid=$1
source ./env_def/read_variables.sh $envid
export dns_name=$2
export end_point=$3

## no longer have to Assume Role of HipOps DNS role to create Route53
## config variable CRMS_DNS_ROLE_ID is also commented out so do not uncomment below row on its own.
#echo "1. Assume DNS Role ..."
#source ./aws/aws_assume_role.sh $CRMS_DNS_ROLE_ID

echo "2. Create a DNS - keep 1 hour to improve performance"
export dns_action=UPSERT
change_id=$(aws route53 change-resource-record-sets --hosted-zone-id $CRMS_DNS_ZONE_ID --change-batch "$(envsubst < aws/set_dns.json)" | jq -r ".ChangeInfo.Id")
echo "Wait for change id: $change_id"
aws route53 wait resource-record-sets-changed --id $change_id


#echo "3. Assume App Role ..."
#source ./aws/aws_assume_role.sh $CRMS_PROV_ROLE_ID
