export no_proxy=$NO_PROXY,artifactory.ext.national.com.au
ENV_ID=$1
source ./env_def/read_variables.sh $ENV_ID

STAGING_FOLDER=$2
ART_LOGIN_PWD=`aws ssm get-parameters --name $crms_arti_uid --with-decryption --region $REGION| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $STAGING_FOLDER ]; then
    mkdir $STAGING_FOLDER
fi

CUR_DIR=`pwd`

cd $STAGING_FOLDER
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/MicrosoftVisualStudio6Runtimes06.msi"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/MicrosoftVisualStudio6RuntimesIMD06.msi"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/WealthCRMS07-9.msi" -o WealthCRMS07_allusers.msi
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/ODBC_CRMS.reg"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/WealthWebRequester01_allusers.msi"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/instantclient_12_2.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -o instantclient_19_6.zip -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/instantclient-basic-windows.x64-19.6.0.0.0dbru (1).zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -o instantclient_19_6_sqlplus.zip -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/instantclient-sqlplus-windows.x64-19.6.0.0.0dbru.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/vcredist_x86.exe"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/VC_redist.x64-for-inst-clt-19.6.exe"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/app.zip"
#curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/ssl_wallet.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -o ssl_wallet.zip -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/$RDS_SSL_WALLET"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/crms_robot_cwallet.sso"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/TowerIDMClient.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/tower_oracle.reg"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/5.6.1_PortMonitorx64_GA_2014-08-12_Build_431_02.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/Lexmark_Universal_v2_UD1_XL.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/Office2016ProPlus64bit.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/VSCodeUserSetup-x64-1.38.1.exe"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/sqldeveloper-20.2.0.175.1842-x64.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/VB6.zip"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/Git-2.23.0-64-bit.exe"
curl -C - -u $crms_arti_uid:$ART_LOGIN_PWD -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/tnsnames1.ora" -o tnsnames.ora

cd "$CUR_DIR"
