#aws/aws_get_db_end_point.sh CRMSD01 Address
#aws/aws_get_db_end_point.sh CRMSD01 Port
#aws rds describe-db-instances |jq -r '.DBInstances[]|select(.DBName=="'$1'").Endpoint.'$2
aws rds describe-db-instances --db-instance-identifier $1|jq -r '.DBInstances[0].Endpoint.'$2
