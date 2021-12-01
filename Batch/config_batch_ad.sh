#!/bin/bash
#/tmp/config_batch_ad.sh $BATCH_AD_PARENT_DOMAIN $BATCH_AD_CHILD_DOMAIN

#This script is used to add AD Group integration to the Gemini web server. Must be run from root.

parent_domain=$1
child_domain=$2

##creating 'ad_auth_group' template variable which will contain the list of all group DNs separated by '|'
echo "%$parent_domain-$child_domain-Delegated-SRVGEMBATCH-SudoRoot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10_ldapadmin
echo "%$parent_domain-$child_domain-Delegated-SRVGEMBATCH-LogonAccess ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/20_svc_acct
echo "%$parent_domain-$child_domain-Delegated-SRVGEMBATCH-SudoSrv-gem-m ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/20_svc_acct

#append all group DN with '|' as separator and add as variable to /etc/facter/facts.d/ldap_auth_group.yaml
echo "ldap_auth_group: CN=$parent_domain-$child_domain-Delegated-SRVGEMBATCH-SudoRoot,OU=Application,OU=$parent_domain,OU=Delegated,OU=Support Groups,OU=Production,DC=$child_domain,DC=national,DC=com,DC=au|CN=$parent_domain-$child_domain-Delegated-SRVGEMBATCH-LogonAccess,OU=Application,OU=$parent_domain,OU=Delegated,OU=Support Groups,OU=Production,DC=$child_domain,DC=national,DC=com,DC=au|CN=$parent_domain-$child_domain-Delegated-SRVGEMBATCH-SudoSrv-gem-m,OU=Application,OU=$parent_domain,OU=Delegated,OU=Support Groups,OU=Production,DC=$child_domain,DC=national,DC=com,DC=au" > /etc/facter/facts.d/ldap_auth_group.yaml

echo 'hui_ldap_enabled: true' > /etc/facter/facts.d/hui_ldap_enabled.yaml
echo "ldap_auth_domain: $child_domain" > /etc/facter/facts.d/hui_ldap_auth_domain.yaml
