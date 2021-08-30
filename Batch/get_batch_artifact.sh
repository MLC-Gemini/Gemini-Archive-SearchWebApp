env_id=$1
stage_folder=$2
source ./env_def/read_variables.sh $env_id
export no_proxy=$NO_PROXY

#art_login_pwd=`aws ssm get-parameters --name $geminiweb_arti_uid --with-decryption --region $REGION| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $stage_folder ]; then
    mkdir $stage_folder
fi

gemini_arti_uid=Srv-gemi-build-np
gemini_login_pwd=zY3eb2XJAPbW

#echo $gemini_arti_uid
#echo $gemini_login_pwd

cd $stage_folder
curl -C - -u $gemini_arti_uid:$gemini_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/GEMINI-build/nginx-1.20.1.tar.gz"
#curl -C - -u $gemini_arti_uid:$gemini_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/GEMINI-build/aspnetcore-runtime-5.0.9-linux-x64.tar.gz"


