#!/usr/bin/bash
#./aws/aws_update_rds_dns.sh CRMSD01 
envid=$1
source ./env_def/read_variables.sh $envid

end_point=$(aws/aws_get_db_end_point.sh $envid Address)
dns_name=$CRMS_RDS_DNS.$CRMS_DNS_ZONE_NAME
./aws/aws_set_dns.sh $envid $dns_name $end_point
