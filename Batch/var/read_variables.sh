#!/usr/bin/bash

# set environment variable based on $env_id.
env_id=$1
echo $env_id

# EC2 variables
SSHACCESSCIDR="10.0.0.0/8"
GEM_KMS="/gemini_archive_web/ec2_kms_key"
BATCH_SERVER_SIZE=50
INSTANCE_TYPE_BATCH="t3.medium"
AWS_PAR_BATCH_IMAGE="/gemini_archive_web/ami_image"
# Aws comman Tags
T_CostCentre="V_Gemini" 
T_ApplicationID="ML0095"
T_AppCategory="D"
T_SupportGroup="WorkManagementProductionSupport"
T_Name="Gemini_Archive_web"
T_BackupOptOut="No"

#artifactory SSM parameter store variable
gemini_arti_ssm_uid="/gemini_archive_web/artifactory_uid"
gemini_arti_ssm_pass="/gemini_archive_web/artifactory_pass"

# SSL Cert SSM parameter store variable
SSL_KEY="/gemini_archive_web/ssl_key"
SSL_CERT="/gemini_archive_web/ssl_cert"
SSL_CHAIN1="/gemini_archive_web/ssl_chain1"
SSL_CHAIN2="/gemini_archive_web/ssl_chain2"

# ASP.NET AWS SSM parameter store variable
SSM_RDS_CONSTR="/gemini_archive_web/rds_con_str"
SSM_ADGROUP="/gemini_archive_web/ad_group"
SSM_TIBCO_IMAGEEBF_SRV_UID="/gemini_archive_web/ticbo_srv_uid"
SSM_TIBCO_IMAGEEBF_SRV_PASS="/gemini_archive_web/ticbo_srv_pass"
SSM_LDAP_SERVER_NAME="/gemini_archive_web/ldap_server_name"
SSM_LDAP_SERVER_PORT="/gemini_archive_web/ldap_port_number"
SSM_LDAP_SERVER_BASEDN="/gemini_archive_web/ldap_base_dn"
SSM_LDAP_SERVER_DOMAIN="/gemini_archive_web/ldap_domain"

#Deploy Bake 
TechnicalService="GeminiArchiveWeb"
Owner="Gemini"
Account="Gemini"
Name="GeminiArchiveWeb-bake-deploy"

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
    T_Environment="nonprod"
    T_EC2_PowerMgt="WKED"
    # Lunch template variable 
    IAM_PROFILE_INST="GeminiProvisioningInstanceProfile"
    KEYPAIR_NAME="GeminiArchWebBuildBoxNonProd"

  # ALB Listner SSL certificate name
    ALB_SSL_CERT_NAME="geminiarchive-app-tst.gemini.awsnp.national.com.au" 

   # Route53 DNS Variable
    GEMINI_DNS_ZONE_NAME="gemini.awsnp.national.com.au"
    GEMINI_DNS_ZONE_ID="Z06453042CMJI49LOR7NB"
    GEMINIWEB_DNS="geminiarchive-app-tst"

elif [[ $env_id == 'prod' ]]; then
  #echo "The variable for prod env"
  # kMS JSON template variable 
    OWNER_ACCOUNT=""
    KMS_ROLE_DELETE_ALLOW="AUR-Resource-AWS-geminiprod-devops-appstack"
    GEMINI_PROV_ROLE_ID="GeminiProvisioningRole"
    IAM_PROFILE_INST="GeminiAppServerInstanceProfile"
    
  # Private VPC
    VPCID=""
    # private subnets
    SUBNETID1="" 
    SUBNETID2=""
    SUBNETID3=""
 
  # EC2 variable
    IAM_PROFILE_PROV="GeminiProvisioningInstanceProfile"
    # Aws Tags
    T_Environment="prod"
    T_EC2_PowerMgt="WKED"
    # Lunch template variable 
    IAM_PROFILE_INST="GeminiProvisioningInstanceProfile"
    KEYPAIR_NAME="GeminiArchWebBuildBoxProd"

  # ALB Listner SSL certificate name
    ALB_SSL_CERT_NAME="geminiarchive-app-prod.gemini.awsnp.national.com.au" 

   # Route53 DNS Variable
    GEMINI_DNS_ZONE_NAME="gemini.aws.national.com.au"
    GEMINI_DNS_ZONE_ID="Z00088892Y517L4T4PLC1"
    GEMINIWEB_DNS="geminiarchive-app-prod"

else
  echo "Please provide the valid env_id for eg. nonprod for NonProd or prod for Production"
fi
