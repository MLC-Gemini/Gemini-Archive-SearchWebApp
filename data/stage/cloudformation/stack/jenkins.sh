#!/usr/bin/env bash

[ "$MOCK" == true ] && return

validate_vars \
  ENVGROUP \
  asset_name_lc \
  ad_parent_domain

#power_mgt='SNAPM'

git_bootstrap_branch='master'
git_bootstrap_jenkinsfile='Jenkinsfile/main'

#case "$ENVGROUP" in
#  'nonprod')
#    github_username='Srv-gemi-gi-np'
#    ldap_username='Srv-gemi-Ldap-np'
#    ;;
#esac

github_username='srv-gemi-gi-np'
ldap_username='srv-gemi-Ldap-np'
#github_username='srv-gemi-gi-p'
#ldap_username='Srv_gemi_Ldap_p'
ssm_git_ssh_key="/$asset_name_lc/srv_github_sshkey"
ssm_ldap_password="/$asset_name_lc/ldap_bind_password"

jenkins_friendly_name="jenkins.$ENVGROUP.$asset_name_lc"
server_certificate_name="$jenkins_friendly_name.$hosted_zone_name"

nopasswd_users='notSet'
sudo_cn="$ad_parent_domain-Delegated-SRVGEMBATCH-SudoRoot"
