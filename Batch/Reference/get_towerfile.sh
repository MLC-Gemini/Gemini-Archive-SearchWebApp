DB_CONN=$1
TOWERFILE=$2
sqlplus -s $DB_CONN << !!
`./Batch/gen_sql.sh $TOWERFILE`
!!
