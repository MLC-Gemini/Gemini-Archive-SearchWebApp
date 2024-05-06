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
GEMINI_PROV_ROLE_ID="GeminiProvisioningRole"
# Provising EC2 variable
IAM_PROFILE_PROV="GeminiProvisioningInstanceProfile"
# Gemini web-server Lunch template EC2 variable
IAM_PROFILE_INST="GeminiAppServerInstanceProfile"
#IAM_PROFILE_INST="GeminiProvisioningInstanceProfile"
# Aws comman Tags
T_CostCentre="cc_1"
T_ApplicationID="1"
T_AppCategory="D"
T_SupportGroup="WorkManagementProductionSupport"
T_Name="Gemini_Archive_web"
T_BackupOptOut="No"
T_PatchCycle="NonProd"
T_Environment="dev"
T_DataClassification="Internal"
T_Owner="test-owner"
#T_PowerMgt="working-days-aest-7am-7pm-on-excluding-holidays"
T_PowerMgt="exempt"
T_MapMigrated="migGWCQZBFJA6"
T_OUName="none"

#artifactory SSM parameter store variable
gemini_arti_ssm_uid="/gemini_archive_web/artifactory_uid"
gemini_arti_ssm_pass="/gemini_archive_web/artifactory_pass"

# SSL Cert SSM parameter store variable
SSL_KEY="/gemini_archive_web/ssl_key"
SSL_CERT="/gemini_archive_web/ssl_cert"
SSL_CHAIN1="/gemini_archive_web/ssl_chain1"
SSL_CHAIN2="/gemini_archive_web/ssl_chain2"

# ASP.NET AWS SSM parameter store variable
SSM_RDS_SERVER="/gemini_archive_web/rds_server"
SSM_RDS_UNAME="/gemini_archive_web/rds_uname"
SSM_RDS_PASS="/gemini_archive_web/rds_pass"
SSM_ADGROUP="/gemini_archive_web/ad_group"
SSM_TIBCO_IMAGEEBF_SRV_UID="/gemini_archive_web/tibco_srv_uid"
SSM_TIBCO_IMAGEEBF_SRV_PASS="/gemini_archive_web/tibco_srv_pass"
SSM_TIBCO_IMAGEEBF_URL="/gemini_archive_web/tibco_imageEBF_url"
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
    OWNER_ACCOUNT="564701137555"
    KMS_ROLE_DELETE_ALLOW="AUR-Resource-AWS-gemininonprod-devops-appstack"

  # Private VPC
    VPCID="vpc-0315f7fa68700cbeb"
    # private subnets
    SUBNETID1="subnet-0b0551340d3c3e2d3"
    SUBNETID2="subnet-0bc8f6436bf9d15e6"
    SUBNETID3="subnet-0e95633450c31214d"

    # Aws Tags
    T_Environment="nonprod"
    T_EC2_PowerMgt="WKED"
    KEYPAIR_NAME="GeminiArchWebBuildBoxNonProd"
    Gemini_SUPPORT_EMAIL="Ajay.Vignesh@mlc.com.au,Robert.Davis@mlc.com.au,Catherine.Sherrin@mlc.com.au"

  # ALB Listner SSL certificate name
    ALB_SSL_CERT_NAME="geminiarchive-app-tst.gem.aws.odev.com.au"

   # Route53 DNS Variable
    GEMINI_DNS_ZONE_NAME="gem.aws.odev.com.au"
    GEMINI_DNS_ZONE_ID="Z103952728QJNDR9HHWXF"
    GEMINIWEB_DNS="geminiarchive-app-tst"

  # EC2 SSH LDAP itegration
    BATCH_AD_PARENT_DOMAIN="aurdev"
    BATCH_AD_CHILD_DOMAIN="BASDEV"

elif [[ $env_id == 'prod' ]]; then
  #echo "The variable for prod env"
  # kMS JSON template variable
    OWNER_ACCOUNT="564701137555"
    KMS_ROLE_DELETE_ALLOW="AUR-Resource-AWS-geminiprod-2FA-devops-appstack"

  # Private VPC
    VPCID="vpc-0315f7fa68700cbeb"
    # private subnets
    SUBNETID1="subnet-0b0551340d3c3e2d3"
    SUBNETID2="subnet-0bc8f6436bf9d15e6"
    SUBNETID3="subnet-0e95633450c31214d"

    # Aws Tags
    T_Environment="prod"
    T_EC2_PowerMgt="SNAPD"
    KEYPAIR_NAME="GeminiArchWebBuildBoxProd"
    Gemini_SUPPORT_EMAIL="gemini_support@mlc.com.au"

  # ALB Listner SSL certificate name
    ALB_SSL_CERT_NAME="geminiarchive-app-prod.gemini.awsnp.national.com.au"

   # Route53 DNS Variable
    GEMINI_DNS_ZONE_NAME="gemini.aws.national.com.au"
    GEMINI_DNS_ZONE_ID="Z00088892Y517L4T4PLC1"
    GEMINIWEB_DNS="geminiarchive-app-prod"

   # EC2 SSH LDAP itegration
    BATCH_AD_PARENT_DOMAIN="aur"
    BATCH_AD_CHILD_DOMAIN="BAS"

else
  echo "Please provide the valid env_id for eg. nonprod for NonProd or prod for Production"
fi
