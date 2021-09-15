#!/usr/bin/bash

env_id=$1
stage_folder=$2
source ./Batch/var/read_variables.sh $env_id

#export http_proxy=http://forwardproxy:3128
#export https_proxy=http://forwardproxy:3128
#export no_proxy=localhost,169.254.169.254,hip.ext.national.com.au,github.aus.thenational.com,artifactory.ext.national.com.au
export no_proxy=$NO_PROXY

# Getting Gemini artifactory service account password form AWS SSM parameter.
gemini_login_pwd=`aws ssm get-parameter --name $gemini_arti_ssm --with-decryption --region "ap-southeast-2" | grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $stage_folder ]; then
    mkdir $stage_folder
fi

#echo $gemini_arti_uid
#echo $gemini_login_pwd

cd $stage_folder
curl -C - -u $gemini_arti_uid:$gemini_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/GEMINI-build/nginx-1.20.1.tar.gz"
#curl -C - -u $gemini_arti_uid:$gemini_login_pwd -O "https://artifactory.ext.national.com.au/artifactory/GEMINI-build/aspnetcore-runtime-5.0.9-linux-x64.tar.gz"


