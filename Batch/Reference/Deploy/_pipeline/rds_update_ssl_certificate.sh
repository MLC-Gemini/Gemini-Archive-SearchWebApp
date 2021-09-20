#_pipeline/rds_update_ssl_certificate.sh CRMS-build ssl_wallet.zip ssl_wallet_2019_refresh.zip https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem 
env_id=$1
current_wallet_name=$2
new_wallet_name=$3
latest_certificate_url=$4

export no_proxy=$NO_PROXY
source ./env_def/read_variables.sh $env_id
ART_LOGIN_PWD=`aws ssm get-parameters --name $crms_arti_uid --with-decryption --region $REGION| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`
#Check to see if the new wallet is already created
if [ "$(curl -u $crms_arti_uid:$ART_LOGIN_PWD --head --silent https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/$new_wallet_name|head -n 1|grep 'Not Found')" == "" ]; then
  echo "New wallet already created, cannot overwrite."
else
	#Let's work in a new folder
	mkdir -p /tmp/ssl_wallet_$$
	cd /tmp/ssl_wallet_$$

	#Get latest certificate from AWS
	curl $latest_certificate_url > rds-ca-xxxx-root.pem

	#Get current wallet from artifactory
	curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/$current_wallet_name"

	#Extract wallet from zip file
	unzip -o $current_wallet_name 

	#Add latest certificate to current wallet
	/oracle/client/bin/orapki wallet add -wallet ssl_wallet -trusted_cert -cert rds-ca-xxxx-root.pem -auto_login_only

	#zip new wallet 
	zip -r $new_wallet_name ssl_wallet

	#Push new zipped wallet to Artifactory
	#TODO: Service account does not have permission to push object to artifactory
	curl -v -u $crms_arti_uid:$ART_LOGIN_PWD --data-binary @$new_wallet_name -X PUT "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/$new_wallet_name"

	#Make sure to set RDS_SSL_WALLET=$new_wallet_name in parameter file
	#e.g. in defalut.cfg(RDS_SSL_WALLET=ssl_wallet_2019_refresh.zip)

