#!/bin/bash

mkdir Jenkins
cd Jenkins
git clone git@github.aus.thenational.com:CRMS/crms-data.git
cd crms-data
make include
# Install Packer
echo "Let's install packer..."
rm -f /sbin/packer /usr/sbin/packer # a symlink to the cracklib library.
current_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r .current_version)
echo $current_version
wget -O packer.zip "https://releases.hashicorp.com/packer/${current_version}/packer_${current_version}_linux_amd64.zip"
unzip packer.zip
mv packer /usr/local/bin/packer
rm packer.zip
PATH="/usr/local/bin:$PATH"
echo "Packer $current_version installed"
#Bake image for Jenkins
echo "Now bake latest image starts..."
SOURCE_AMI=latest STACK=jenkins ENVGROUP=nonprod bash -x bake.sh
echo "Latest AMI bake complete"
#Uninstall existing Jenkins stack if exists
echo "Uninstall Jenkins if already installed"
SOURCE_AMI=latest STACK=jenkins ENVGROUP=nonprod bash -x delete_stack.sh
#Install Jenkins from latest AMI
echo "Install Jenkins with latest AMI starts..."
SOURCE_AMI=latest STACK=jenkins ENVGROUP=nonprod bash -x deploy_stack.sh
echo "Installation of Jenkins complete"
