#!/usr/bin/bash

env_id=$1
echo $env_id

# set environment variable based on $env_id.

#artifactory variable
gemini_arti_uid="Srv-gemi-build-np"
gemini_arti_ssm="/gemini_archive_web/artifactory"

NO_PROXY="localhost,169.254.169.254,hip.ext.national.com.au,s3.ap-southeast-2.amazonaws.com"

if [[ $env_id == 'nonprod' ]]; then
    # kMS JSON template variable 
    OWNER_ACCOUNT="998622627571"
    KMS_ROLE_DELETE_ALLOW="AUR-Resource-AWS-gemininonprod-devops-appstack"
    #IAM_PROFILE_PROV="GeminiProvisioningInstanceProfile"
    GEMINI_PROV_ROLE_ID="GeminiProvisioningRole"
    IAM_PROFILE_INST="GeminiAppServerInstanceProfile"
    
    # Tooling VPC
    #VPCID="vpc-0a78b82ba9196ca94" 
    # Private VPC
    VPCID="vpc-0ecf6cd42dacf1a57"
    # tooling subnets 
    #SUBNETID1="subnet-01470aa7fd78e4888" 
    # private subnets
    SUBNETID1="subnet-01132417d1533351a" 
    SUBNETID2="subnet-00f9ae140fbbeaa86"
    SUBNETID3="subnet-01ba8cd53df612f02"

    SSHACCESSCIDR="10.0.0.0/8"
    GEM_KMS="/gemini_archive_web/ec2_key"
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

    AWS_PAR_BATCH_IMAGE="/gemini_archive_web/ami_image"

    #Deploy Bake 
    TechnicalService="GeminiWeb"
    Owner="GeminiWeb"
    Account="GeminiWeb"
    Name="GeminiWeb-bake-deploy"

   # Lunch template variable 
    IAM_PROFILE_INST="GeminiProvisioningInstanceProfile"
    KEYPAIR_NAME="GeminiArchWebBuildBoxNonProd"

elif [[ $env_id == 'prod' ]]; then
  echo "The variable for prod env"

else
  echo "Please provide the valid env_id for eg. nonpord for NonProd or prod for Production"
fi