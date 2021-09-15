#!/usr/bin/env bash

[ "$MOCK" == true ] && return

vpc_id_private='vpc-0ecf6cd42dacf1a57'
vpc_id_tooling='vpc-0a78b82ba9196ca94'

vpc_cidr_private='10.153.46.0/23'
vpc_cidr_tooling='10.156.193.0/24'

#remote_access_1='10.40.37.0/32'
#remote_access_2='10.40.37.0/24'
#remote_access_3='10.57.63.0/32'
#remote_access_4='10.57.63.0/24'
#remote_access_5='10.1.97.0/24'
#remote_access_6='10.1.97.0/32'
#remote_access_8='10.156.193.0/32'

s3_vpc_endpoint_private='vpce-07099ab014cb0411a'
s3_vpc_endpoint_tooling='vpce-049c71c2fe8ff6e96'

subnets_private='subnet-01132417d1533351a,subnet-00f9ae140fbbeaa86,subnet-01ba8cd53df612f02'
subnets_tooling='subnet-01470aa7fd78e4888,subnet-0f0742ff8bd72c7ab,subnet-04f25a4cac3759799'

#subnet_id='subnet-01132417d1533351a' # AZ-a
#subnets='subnet-00f9ae140fbbeaa86,subnet-01132417d1533351a,subnet-01ba8cd53df612f02'
power_mgt='OSHSD'

#hosted_zone_id='Z3RQD0UV5PMRBG'  # one for prod and nonprod
hosted_zone_id='Z06453042CMJI49LOR7NB'
hosted_zone_name='extnp.national.com.au'

#host_name_env='D'

ad_domain='dev'
#db_name='Gemini'
#multi_az='false'

aws_account_no='998622627571'
#ami_users="$aws_account_no"

iam_account_arn="arn:aws:iam::$aws_account_no"

iam_app_server_instance_profile='GeminiAppServerInstanceProfile'
iam_app_server_instance_profile_arn="$iam_account_arn:role/$iam_app_server_instance_profile"

iam_instance_profile='GeminiProvisioningInstanceProfile'
iam_instance_profile_arn="$iam_account_arn:role/$iam_instance_profile"

iam_hip_base_instance_profile='HIPBaseInstanceProfile'
iam_hip_base_instance_profile_arn="arn:aws:iam::$iam_account_arn:instance-profile/$iam_hip_base_instance_profile"

iam_provisioning_role='GeminiProvisioningRole'
iam_provisioning_role_arn="$iam_account_arn:role/$iam_provisioning_role"

iam_devops_appstack_role='AUR-Resource-AWS-gemininonprod-devops-appstack'
iam_devops_appstack_role_arn="$iam_account_arn:role/$iam_devops_appstack_role"

iam_hip_mfa_admin_role='AUR-Resource-AWS-gemininonprod-2FA-hip-admin'
iam_hip_mfa_admin_role_arn="$iam_account_arn:role/$iam_hip_mfa_admin_role"

iam_autoscaling_service_role='AWSServiceRoleForAutoScaling'
iam_autoscaling_service_role_arn="$iam_account_arn:role/aws-service-role/autoscaling.amazonaws.com/$iam_autoscaling_service_role"

iam_elasticloadbalancing_service_role='AWSServiceRoleForElasticLoadBalancing'
iam_elasticloadbalancing_service_role_arn="$iam_account_arn:role/aws-service-role/elasticloadbalancing.amazonaws.com/$iam_elasticloadbalancing_service_role"

hip_notify_high_topic='arn:aws:sns:ap-southeast-2:998622627571:HIPNotifyGEMINIHighTopic'
hip_notify_medium_topic='arn:aws:sns:ap-southeast-2:998622627571:HIPNotifyGEMINIMedTopic'
hip_notify_low_topic='arn:aws:sns:ap-southeast-2:998622627571:HIPNotifyGEMINILowTopic'

asset_notify_topic='arn:aws:sns:ap-southeast-2:998622627571:GEMININotifyTopic'

#parent_ad_domain='BASDEV'
#child_ad_domain='aurdev'

#ctm_agent_to_server_port='9025'
#ctm_master_ip='10.47.60.214'
#ctm_master_short='cmdevv8'
#ctm_server_to_agent_port='9026'
dns_update_role='arn:aws:iam::803264201466:role/HIPExtNpRoute53UpdateRole8'

ad_child_domain='aurdev'
ad_parent_domain='BASDEV'
ad_common_names="$ad_parent_domain-Delegated-SRVGEMINI-SudoRoot"
group_cn="$ad_parent_domain-Delegated-SRVGEMINI-SudoRoot"

ad_group_admin='NotSet'
ad_group_release='NotSet'
ad_group_read='NotSet'

#server_certificate_name='arn:aws:iam::998622627571:server-certificate/jenkins.nonprod.gemini.extnp.national.com.au'

github_username='srv-gemi-gi-np'
ldap_username='srv-gemi-Ldap-np'
