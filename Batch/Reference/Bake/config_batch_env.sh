#This script is used to add/update an environment
#!/usr/bin/bash
#config_batch_server.sh $dbname $uid $db_dns $db_ssl_port
export AWS_DEFAULT_REGION=ap-southeast-2
export http_proxy=http://forwardproxy:3128
export https_proxy=http://forwardproxy:3128
export no_proxy=localhost,169.254.169.254,hip.ext.national.com.au,github.aus.thenational.com,artifactory.ext.national.com.au

dbname=$1
uid=$2
db_dns=$3
db_ssl_port=$4

dbname_lowercase=${dbname,,}

#1. Add/replace TNSNAMES entry
sed -i "/$dbname/d" /opt/oracle/tnsnames/tnsnames.ora
echo "$dbname.world=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCPS)(HOST=$db_dns)(PORT=$db_ssl_port)))(CONNECT_DATA=(SID=$dbname))(SECURITY=(SSL_SERVER_CERT_DN=\"C=US,ST=Washington,L=Seattle,O=Amazon.com,OU=RDS,CN=$db_dns\")))" |tee -a /opt/oracle/tnsnames/tnsnames.ora

#2. Create directory structure in EFS for storing received files
#Note: /extract is a symbolic link to /extract
# AKM
mkdir -p /extract/$dbname_lowercase/akm/receive
mkdir -p /extract/$dbname_lowercase/akm/archive
mkdir -p /extract/$dbname_lowercase/akm/log
# EDW
mkdir -p /extract/$dbname_lowercase/edw/receive
mkdir -p /extract/$dbname_lowercase/edw/archive
mkdir -p /extract/$dbname_lowercase/edw/log
# PROMPT
mkdir -p /extract/$dbname_lowercase/prompt/receive
mkdir -p /extract/$dbname_lowercase/prompt/archive
mkdir -p /extract/$dbname_lowercase/prompt/log
mkdir -p /extract/$dbname_lowercase/prompt/logs
# TOWER
mkdir -p /extract/$dbname_lowercase/tower/receive
mkdir -p /extract/$dbname_lowercase/tower/archive
mkdir -p /extract/$dbname_lowercase/tower/log
# tmp
mkdir -p /extract/$dbname_lowercase/tmp

#Make sure extract folder is accessible(read/write) by crmsAFT grouo
chown -R crmsAFT /extract/$dbname_lowercase
chgrp -R crmsAFT /extract/$dbname_lowercase
chmod -R g+rw /extract/$dbname_lowercase

#3. Create environment specific folder, copy source code to it, create configuration script(crmsenv) 
#3.1
mkdir -p /opt2/$dbname_lowercase
#3.2
cp -rf /tmp/scripts /opt2/$dbname_lowercase
#3.3
echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2:\$LD_LIBRARY_PATH
export PATH=.:/opt/oracle/instantclient_12_2:\$PATH
export TNS_ADMIN=/opt/oracle/tnsnames
export CONNSTR=/
export ORACLE_SID=$dbname
export CRMS_EXTRACT_BASE=/extract/$dbname_lowercase
" > /opt2/$dbname_lowercase/scripts/crmsenv

#Make sure program folder is accessible(read/write/execute) by crmsAFT group
chown -R crmsAFT /opt2/$dbname_lowercase
chgrp -R crmsAFT /opt2/$dbname_lowercase
chmod -R g+rw /opt2/$dbname_lowercase
chmod g+x /opt2/$dbname_lowercase/scripts/crmsenv
chmod g+x /opt2/$dbname_lowercase/scripts/crms_load_data_extract.sh

#4. Create wallet with password for auto logon
crms_passwd=$(/tmp/crms_decrypt $(aws ssm get-parameter --name PWD-$dbname --with-decryption --query Parameter.Value --output text))
#To cater for chaning password without recreating ec2 instance
/oracle/client/bin/mkstore -wrl /opt/oracle/tnsnames/ssl_wallet -deleteCredential $dbname 
/oracle/client/bin/mkstore -wrl /opt/oracle/tnsnames/ssl_wallet -createCredential $dbname $uid $crms_passwd
