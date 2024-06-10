#!/bin/bash

#This script is used to add AD Group integration to the Gemini web server. Must be run from root.

##creating 'ad_auth_group' template variable which will contain the list of all group DNs separated by '|'
echo "ROL_IFL_IT_Gemini_Sup ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10_ldapadmin
echo "ROL_IFL_IT_Gemini_Sup ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01_service_accounts
echo "ROL_IFL_IT_Gemini_Sup ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/20_svc_acct
echo "ROL_APP_Gemini ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10_ldapadmin
echo "ROL_APP_Gemini ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/01_service_accounts
echo "ROL_APP_Gemini ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/20_svc_acct

#append all group DN with '|' as separator and add as variable to /etc/facter/facts.d/ldap_auth_group.yaml
echo "ldap_auth_group: CN=ROL_IFL_IT_Gemini_Sup,OU=Application,OU=$parent_domain,OU=Delegated,OU=Support Groups,OU=Production,DC=gem,DC=aws,DC=odev,DC=com,DC=au|CN=ROL_APP_Gemini,OU=Application,OU=Delegated,OU=Support Groups,OU=Production,DC=gem,DC=aws,DC=odev,DC=com,DC=au" > /etc/facter/facts.d/ldap_auth_group.yaml

echo 'hui_ldap_enabled: true' > /etc/facter/facts.d/hui_ldap_enabled.yaml
echo "ldap_auth_domain: ROL" > /etc/facter/facts.d/hui_ldap_auth_domain.yaml
