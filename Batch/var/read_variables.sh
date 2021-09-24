#!/usr/bin/bash

# set environment variable based on $env_id.
env_id=$1
echo $env_id

# EC2 variables
SSHACCESSCIDR="10.0.0.0/8"
GEM_KMS="/gemini_archive_web/ec2_key"
BATCH_SERVER_SIZE=50
INSTANCE_TYPE_BATCH="t3.medium"
AWS_PAR_BATCH_IMAGE="/gemini_archive_web/ami_image"

#artifactory variable
gemini_arti_ssm_uid="/gemini_archive_web/artifactory_uid"
gemini_arti_ssm_pass="/gemini_archive_web/artifactory_pass"

# SSL Cert SSM parameter store variable
SSL_KEY="/gemini_archive_web/ssl_key"
SSL_CERT="/gemini_archive_web/ssl_cert"
SSL_CHAIN1="/gemini_archive_web/ssl_chain1"
SSL_CHAIN2="/gemini_archive_web/ssl_chain2"

#Deploy Bake 
TechnicalService="GeminiWeb"
Owner="GeminiWeb"
Account="GeminiWeb"
Name="GeminiWeb-bake-deploy"

#NO_PROXY=localhost,169.254.169.254,hip.ext.national.com.au,github.aus.thenational.com,artifactory.ext.national.com.au

if [[ $env_id == 'nonprod' ]]; then
    # kMS JSON template variable 
    OWNER_ACCOUNT="998622627571"
    KMS_ROLE_DELETE_ALLOW="AUR-Resource-AWS-gemininonprod-devops-appstack"
    GEMINI_PROV_ROLE_ID="GeminiProvisioningRole"
    IAM_PROFILE_INST="GeminiAppServerInstanceProfile"
    
    # Private VPC
    VPCID="vpc-0ecf6cd42dacf1a57"
    
    # private subnets
    SUBNETID1="subnet-01132417d1533351a" 
    SUBNETID2="subnet-00f9ae140fbbeaa86"
    SUBNETID3="subnet-01ba8cd53df612f02"
 
    # EC2 variable
    IAM_PROFILE_PROV="GeminiProvisioningInstanceProfile"

    # Aws Tags
    T_CostCentre="V_Gemini" 
    T_ApplicationID="ML0095"
    T_Environment="nonprod"
    T_AppCategory="B"
    T_SupportGroup="WorkManagementProductionSupport"
    T_Name="Gemini_web"
    #T_EC2_PowerMgt="EXTSW,0,1"
    T_EC2_PowerMgt="EXTSW"
    T_BackupOptOut="No"

   # Lunch template variable 
    IAM_PROFILE_INST="GeminiProvisioningInstanceProfile"
    KEYPAIR_NAME="GeminiArchWebBuildBoxNonProd"

   # Route53 DNS Variable
    GEMINI_DNS_ZONE_NAME="gemini.awsnp.national.com.au"
    GEMINI_DNS_ZONE_ID="Z06453042CMJI49LOR7NB"
    GEMINIWEB_DNS="geminiarchive-app-tst"

   # ALB Listner SSL certificate name
    ALB_SSL_CERT_NAME="geminiarchive-app-tst.gemini.awsnp.national.com.au" 

elif [[ $env_id == 'prod' ]]; then
  echo "The variable for prod env"

else
  echo "Please provide the valid env_id for eg. nonprod for NonProd or prod for Production"
fi