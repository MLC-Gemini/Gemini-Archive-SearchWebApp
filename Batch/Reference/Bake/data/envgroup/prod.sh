#!/usr/bin/env bash

[ "$MOCK" == true ] && return

vpc_id_private="vpc-0c0121a7c332d8b22"
vpc_id_tooling="vpc-0790e55aa9247cf85"

vpc_cidr_private="10.154.94.0/23"
vpc_cidr_tooling="10.154.93.0/24"

remote_access_1='10.52.95.241/32'
remote_access_2='10.56.61.243/32'
remote_access_3='10.154.0.0/16'
remote_access_4='10.154.0.0/24'
remote_access_5='10.154.0.0/32'
remote_access_6='10.1.65.25/32'

s3_vpc_endpoint_private="vpce-091750750ed35eb2e"
s3_vpc_endpoint_tooling="vpce-0ef211fda293ce9e5"

subnets_private="subnet-0909479f29bc9f90c,subnet-0507e89e99c22c1f0,subnet-0fd7f4b9c8a849f64"
subnets_tooling="subnet-066b4ef62823e032c,subnet-02bc490e5acc67496,subnet-000fef72afebe5723"

subnets="subnet-0909479f29bc9f90c,subnet-0507e89e99c22c1f0,subnet-0fd7f4b9c8a849f64"
power_mgt='OSHS'

hosted_zone_id='Z34EI9HR3JQ3OR'  # one for prod and nonprod
hosted_zone_name='ext.national.com.au'

aws_account_no="937709052626"
ami_users="$aws_account_no"

iam_account_arn="arn:aws:iam::$aws_account_no"

iam_app_server_instance_profile="GeminiAppServerInstanceProfile"
iam_app_server_instance_profile_arn="$iam_account_arn:role/$iam_app_server_instance_profile"

iam_instance_profile="GeminiProvisioningInstanceProfile"
iam_instance_profile_arn="$iam_account_arn:role/$iam_instance_profile"

iam_hip_base_instance_profile='HIPBaseInstanceProfile'
iam_hip_base_instance_profile_arn="arn:aws:iam::$iam_account_arn:instance-profile/$iam_hip_base_instance_profile"

iam_provisioning_role="GeminiProvisioningRole"
iam_provisioning_role_arn="$iam_account_arn:role/$iam_provisioning_role"

iam_devops_appstack_role="AUR-Resource-AWS-geminiprod-2FA-devops-appstack"
iam_devops_appstack_role_arn="$iam_account_arn:role/$iam_devops_appstack_role"

iam_hip_mfa_admin_role="AUR-Resource-AWS-geminiprod-2FA-hip-admin"
iam_hip_mfa_admin_role_arn="$iam_account_arn:role/$iam_hip_mfa_admin_role"

iam_autoscaling_service_role='AWSServiceRoleForAutoScaling'
iam_autoscaling_service_role_arn="$iam_account_arn:role/aws-service-role/autoscaling.amazonaws.com/$iam_autoscaling_service_role"

iam_elasticloadbalancing_service_role='AWSServiceRoleForElasticLoadBalancing'
iam_elasticloadbalancing_service_role_arn="$iam_account_arn:role/aws-service-role/elasticloadbalancing.amazonaws.com/$iam_elasticloadbalancing_service_role"

hip_notify_high_topic='arn:aws:sns:ap-southeast-2:937709052626:HIPNotifyGEMINIHighTopic' 
hip_notify_medium_topic='arn:aws:sns:ap-southeast-2:937709052626:HIPNotifyGEMINIMedTopic'
hip_notify_low_topic='arn:aws:sns:ap-southeast-2:937709052626:HIPNotifyGEMINILowTopic' 

asset_notify_topic="arn:aws:sns:ap-southeast-2:937709052626:GeminiProd"

parent_ad_domain='BAS'
child_ad_domain='aur'

ctm_agent_to_server_port='9005'
ctm_master_ip='10.47.122.219'
ctm_master_short='cmprodv8'
ctm_server_to_agent_port='9006'

ad_child_domain='aur'
ad_parent_domain='BAS'
ad_common_names="$ad_parent_domain-Delegated-SRVGEMBATCH-SudoRoot"

server_certificate_name='arn:aws:iam::937709052626:server-certificate/jenkins.prod.gemini.ext.national.com.au'

github_username='srv_gemi_gi_p'
ldap_username='srv_gemi_Ldap_p'
