env_id=$1
stage_folder=$2
source ./env_def/read_variables.sh $env_id
export no_proxy=$NO_PROXY

art_login_pwd=`aws ssm get-parameters --name $crms_arti_uid --with-decryption --region $REGION| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $stage_folder ]; then
    mkdir $stage_folder
fi

#echo $crms_arti_uid
#echo $art_login_pwd
#echo $BUILD_STAGE

stunnel_pkg_file=stunnel-5.59.tar.gz

cd $stage_folder
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/linuxx64_12201_client.zip"
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/instantclient-basic-linux.x64-12.2.0.1.0.zip"
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip"
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/instantclient-tools-linux.x64-12.2.0.1.0.zip"
#curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/ssl_wallet.zip"
curl -C - -u $crms_arti_uid:$art_login_pwd -o ssl_wallet.zip -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/$RDS_SSL_WALLET"
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/libwsman3-2.6.9-199.1.x86_64.rpm"
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/powershell-6.2.0-1.rhel.7.x86_64.rpm"
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/wsmancli-2.6.0-59.2.x86_64.rpm"
#curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/Control-M-V8-Binary.zip"
#Use standard control-m software from mlcdevops
#curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-build/BMC/ControlM/ControlM-Agent-fixpack-8.0.00.500-linux-x86_64.tar.gz"
#curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-build/BMC/ControlM/ControlM-Agent-install-8.0.00-linux-x86_64.tar.gz"
if [[ "$env_id" == "$BUILD_STAGE" ]]; then
    echo "This is non-prod download"
    curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-build/BMC/ControlM/ControlM-Agent-install-9.0.19.100_Linux-x86_64.tar.gz"
else
    echo "This is prod download"
    curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-release/BMC/ControlM/ControlM-Agent-install-9.0.19.100_Linux-x86_64.tar.gz"
fi
wget -q https://www.stunnel.org/downloads/$stunnel_pkg_file -O $stunnel_pkg_file
