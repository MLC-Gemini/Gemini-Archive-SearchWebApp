#./_pipeline/clone_rds.sh $from_db $to_db
from_db=CRMSD01
to_db=CRMSP01
tmp_db_snapshot=tmp-db-snap-$(date +%Y-%m-%d-%H-%M-%S)

from_db=$1
to_db=$2

echo "1. Create db-snapshot from "$from_db
aws rds create-db-snapshot --db-instance-identifier $from_db --db-snapshot-identifier $tmp_db_snapshot 
aws rds wait db-snapshot-available --db-instance-identifier $from_db


echo "2. Refresh db using refresh pipeline"
source env_def/read_variables.sh $to_db
./_pipeline/create_db.sh $to_db arn:aws:rds:$REGION:$OWNER_ACCOUNT:snapshot:$tmp_db_snapshot

echo "3. Drop tmp snapshot"
aws rds delete-db-snapshot --db-snapshot-id $tmp_db_snapshot
