env_id=$1
stage_folder=$2
source ./env_def/read_variables.sh $env_id
export no_proxy=$NO_PROXY

#art_login_pwd=`aws ssm get-parameters --name $geminiweb_arti_uid --with-decryption --region $REGION| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $stage_folder ]; then
    mkdir $stage_folder
fi

#echo $crms_arti_uid
#echo $art_login_pwd
#echo $BUILD_STAGE

cd $stage_folder
#curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/$BUILD_STAGE/linuxx64_12201_client.zip"
curl -C - -u AUR\Srv-gemi-build-np:zY3eb2XJAPbW -O "https://artifactory.ext.national.com.au/artifactory/GEMINI-build/nginx-1.20.1.tar.gz"
curl -C - -u AUR\Srv-gemi-build-np:zY3eb2XJAPbW -O "https://artifactory.ext.national.com.au/artifactory/GEMINI-build/aspnetcore-runtime-5.0.9-linux-x64.tar.gz"

if [[ "$env_id" == "$BUILD_STAGE" ]]; then
    echo "This is non-prod download"
    #curl -C - -u $geminiweb_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-build/BMC/ControlM/ControlM-Agent-install-9.0.19.100_Linux-x86_64.tar.gz"
else
    echo "This is prod download"
    #curl -C - -u $geminiweb_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-release/BMC/ControlM/ControlM-Agent-install-9.0.19.100_Linux-x86_64.tar.gz"
fi

