#!/usr/bin/bash

env_id=$1
echo $env_id

# set environment variable based on $env_id.

#artifactory variable
gemini_arti_uid="Srv-gemi-build-np"

if [[ $env_id == 'nonprod' ]]; then
    # Tooling VPC
    #VPCID="vpc-0a78b82ba9196ca94" 
    # Private VPC
    VPCID="vpc-0ecf6cd42dacf1a57"
    # tooling subnet a
    #SUBNETID1="subnet-01470aa7fd78e4888" 
    # private subnet 2a
    SUBNETID1="subnet-01132417d1533351a" 

    SSHACCESSCIDR="10.0.0.0/8"
    GEM_KMS="myTest"
    #GEM_KMS="gemini_archive_web_ec2"
    BATCH_SERVER_SIZE=50
    INSTANCE_TYPE_BATCH="t3.small"
    IAM_PROFILE_PROV="GeminiProvisioningInstanceProfile"

    # Aws Tags
    T_CostCentre="V_Gemini" 
    #T_ApplicationID="M4456"
    T_ApplicationID="ML0095"
    T_Environment="nonprod"
    T_AppCategory="B"
    T_SupportGroup="WorkManagementProductionSupport"
    T_Name="Gemini_web"
    #T_EC2_PowerMgt="EXTSW,0,1"
    T_EC2_PowerMgt="EXTSW"
    T_BackupOptOut="No"

    AWS_PAR_BATCH_IMAGE="GeminiArchiveWeb"

    #Deploy Bake 
    TechnicalService="GeminiWeb"
    Owner="GeminiWeb"
    Account="GeminiWeb"
    Name="GeminiWeb-bake-deploy"

elif [[ $env_id == 'prod' ]]; then
  echo "The variable for prod env"

else
  echo "Please provide the valid env_id for eg. nonpord for NonProd or prod for Production"
fi