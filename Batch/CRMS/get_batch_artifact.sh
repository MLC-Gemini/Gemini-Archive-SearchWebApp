#./Batch/get_batch_artifact.sh 
source ./env_def/read_variables.sh 
export no_proxy=$NO_PROXY

art_login_pwd=`aws ssm get-parameters --name $crms_arti_uid --with-decryption --region $REGION| grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $stage_folder ]; then
    mkdir $stage_folder
fi

cd $stage_folder
#Use standard control-m software from mlcdevops
curl -C - -u $crms_arti_uid:$art_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/MLCDEVOPS-build/BMC/ControlM/ControlM-Agent-install-9.0.19.100_Linux-x86_64.tar.gz"
