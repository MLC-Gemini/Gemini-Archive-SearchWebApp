#!/usr/bin/env bash

. /etc/profile.d/proxy.sh
export no_proxy=$no_proxy,s3.ap-southeast-2.amazonaws.com
yum -y update
yum update aws-cfn-bootstrap

yum -y install \
  jq epel-release \
  ShellCheck \
  git bc ruby \
  colordiff \
  gcc python-devel

curl \
    https://raw.githubusercontent.com/kward/shunit2/6d17127dc12f78bf2abbcb13f72e7eeb13f66c46/shunit2 \
    -o /usr/local/bin/shunit2

curl \
    https://raw.githubusercontent.com/alexharv074/scripts/master/DiffHighlight.pl \
    -o /usr/local/bin/DiffHighlight.pl

# Install Packer
rm -f /sbin/packer /usr/sbin/packer # a symlink to the cracklib library.

current_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | \
  jq -r .current_version)
wget -O packer.zip \
  "https://releases.hashicorp.com/packer/${!current_version}/packer_${!current_version}_linux_amd64.zip"

unzip packer.zip
mv packer /usr/local/bin/packer
rm -f packer.zip

pip install awscli --upgrade
pip install bs4
pip install yamllint

configure_ad() {
  local cn1="${ADCommonName}" # e.g. BAS-Delegated-SRVONCBATCH-SudoRoot

  echo 'hui_ldap_enabled: true' \
    > /etc/facter/facts.d/hui_ldap_enabled.yaml

  echo "ldap_auth_group: \
CN=$cn1,\
OU=Application,OU=${ADParentDomain},OU=Delegated,OU=Support Groups,OU=Production,\
DC=${ADChildDomain},DC=national,DC=com,DC=au\
" \
    > /etc/facter/facts.d/ldap_auth_group.yaml
  echo "ldap_auth_domain: ${ADChildDomain}" \
    > /etc/facter/facts.d/hui_ldap_auth_domain.yaml

  local cn1_lc="$(tr '[A-Z]' '[a-z]' <<< $cn1)"

  echo "%$cn1_lc ALL=(ALL) NOPASSWD: ALL" \
    >> /etc/sudoers.d/20_ldapadmins
}

[ "${ADCommonName}" != "notSet" ] && configure_ad
