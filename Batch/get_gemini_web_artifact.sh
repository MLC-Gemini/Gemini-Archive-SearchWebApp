#!/usr/bin/bash

env_id=$1
stage_folder=$2
source ./Batch/var/read_variables.sh $env_id

# Getting Gemini artifactory service account password form AWS SSM parameter.
gemini_arti_uid=`aws ssm get-parameter --name $gemini_arti_ssm_uid --with-decryption --region "ap-southeast-2" | grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`
gemini_login_pwd=`aws ssm get-parameter --name $gemini_arti_ssm_pass --with-decryption --region "ap-southeast-2" | grep Value | awk '{print $2}'|sed 's/"//g'|sed 's/,$//g'`

if [ ! -d $stage_folder ]; then
    mkdir $stage_folder
fi

cd $stage_folder
# Download nginx package from nexus
curl -C - -u $gemini_arti_uid:$gemini_login_pwd -O "https://nexus.itt.aws.odev.com.au/repository/GEMINI-build/nginx/nginx-1.25.3.tar.gz"
