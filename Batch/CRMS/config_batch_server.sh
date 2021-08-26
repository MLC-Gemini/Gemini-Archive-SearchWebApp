#!/usr/bin/bash
#/tmp/config_batch_server.sh fs-de815fe6 $SSM_PUBKEY $support_topic_arn $SSM_SERVER_HOST_KEY $TWR_SCPKEY $TWR_SSM_KEY

#This script is used to add/update machine level of configuration
#config_batch_server_1.sh $efsid $SSM_PUBKEY $support_topic_arn 


#Dev sample
#efsid=fs-de815fe6
#ssm_pubkey=AFT_PUBKEY_DEV 
#support_topic_arn=arn:aws:sns:ap-southeast-2:040653843081:SNS_Support_NonProd
#ssm_server_host_key=AFT_HOST_KEY_DEFAULT

#Get environment
source ~ec2-user/.bash_profile

efsid=$1
ssm_pubkey=$2
support_topic_arn=$3
ssm_server_host_key=$4
twr_scpkey=$5
twr_host_key=$6

#
#IBM control-m server stores our host key fingerprint in there known host file.
#When a new ec2 instance is created from autoscaling group, aws automatically creating new host key, this is causing IBM control-m server to fail authentication
#To work around this issue, we use a statics host key from SSM store for each environment.
#

#Retrive SSH Server Host key from SSM, if not already placed in SSM store, create a new pair
aws ssm get-parameter --name ${ssm_server_host_key} --with-decryption --query Parameter.Value --output text  > /etc/ssh/ssh_host_ecdsa_key 2>x$$x
if grep -q ParameterNotFound x$$x; then
	#SSM store were not uploaded, create a new keypair and store them in SSM store
	ssh-keygen -t ecdsa -b 256 -N "" -f /etc/ssh/ssh_host_ecdsa_key <<< "y"
	sed -i 's/ root@ip-.*//' /etc/ssh/ssh_host_ecdsa_key.pub
	aws ssm put-parameter --name ${ssm_server_host_key} --type "SecureString" --value "$(cat /etc/ssh/ssh_host_ecdsa_key)"
	aws ssm put-parameter --name ${ssm_server_host_key}_PUB --type "SecureString" --value "$(cat /etc/ssh/ssh_host_ecdsa_key.pub|sed 's/ root@ip-.*//')"
	rm x$$x
	rm x_ssh_$$
	rm x_ssh_$$.pub
else
	aws ssm get-parameter --name ${ssm_server_host_key}_PUB --with-decryption --query Parameter.Value --output text  > /etc/ssh/ssh_host_ecdsa_key.pub
fi
#Prepare this key for ASG
cp "/etc/ssh/ssh_host_ecdsa_key" "/etc/ssh/ssh_host_ecdsa_key_AFT"
cp "/etc/ssh/ssh_host_ecdsa_key.pub" "/etc/ssh/ssh_host_ecdsa_key_AFT.pub"

aws ssm get-parameter --name ${twr_host_key} --with-decryption --query Parameter.Value --output text  > /etc/ssh/ssh_host_ecdsa_key_TWR 2>y$$y
if grep -q ParameterNotFound y$$y; then
        #SSM store were not uploaded, create a new keypair and store them in SSM store
        ssh-keygen -t ecdsa -b 256 -N "" -f /etc/ssh/ssh_host_ecdsa_key_TWR <<< "t"
        sed -i 's/ root@ip-.*//' /etc/ssh/ssh_host_ecdsa_key_TWR.pub
        aws ssm put-parameter --name ${twr_host_key} --type "SecureString" --value "$(cat /etc/ssh/ssh_host_ecdsa_key_TWR)"
        aws ssm put-parameter --name ${twr_host_key}_PUB --type "SecureString" --value "$(cat /etc/ssh/ssh_host_ecdsa_key_TWR.pub|sed 's/ root@ip-.*//')"
        rm y$$y
        rm y_ssh_$$
        rm y_ssh_$$.pub
else
        aws ssm get-parameter --name ${twr_host_key}_PUB --with-decryption --query Parameter.Value --output text  > /etc/ssh/ssh_host_ecdsa_key_TWR.pub
fi

echo "1. Mount to EFS"
#Instead of doing mount targets query in AppServer, we save mount targets list to a tmp file for later use, e.g. in launch configuration
aws efs describe-mount-targets --file-system-id ${efsid} > /tmp/mount-targets.lst

#Fix hosts file
sed -i "/$efsid.efs.ap-southeast-2.amazonaws.com/d" /etc/hosts
echo "$(cat /tmp/mount-targets.lst| jq -r '.MountTargets[]|select (.SubnetId=="'$(aws ec2 describe-instances --instance-ids $(curl http://169.254.169.254/latest/meta-data/instance-id) | jq -r ".Reservations[0].Instances[0].SubnetId")'").IpAddress')  $efsid.efs.ap-southeast-2.amazonaws.com" >> /etc/hosts

#Add to mount table
sed -i "/$efsid/d" /etc/fstab
echo "$efsid	/extract	efs _netdev,nofail,tls 0 0" >> /etc/fstab

#Force a mount
mkdir /extract
chown root:root /extract
mount -a -t efs defaults

echo "2. Create User & Groups"
create_group() {
  local group=$1
  local gid=$2
  lgroupadd -g "$gid" "$group"
}

create_user() {
  local user=$1
  local groups=$2
  local uid=$3
  local pubkey=$4
  local privkey=$5
  local home=$6

  [ -z "$home" ] && home="$batch_mount/users/$user"

  if [ -z "$uid" ] ; then
    usermod -G "$groups" "$user"
    return
  fi

  luseradd -u "$uid" -g "$uid" -d "$home" -M "$user"
  [ ! -z "$groups" ] && usermod -a -G "$groups" "$user"

  mkdir -p "$home/.ssh"
  #echo "ssh-rsa $pubkey" > "$home/.ssh/authorized_keys"
  aws ssm get-parameter --name $pubkey --with-decryption --query Parameter.Value --output text  > "$home/.ssh/authorized_keys"
  chown -R "$user:$user" "$home"
  chmod 0744 "$home"
  chmod 0700 "$home/.ssh"
  chmod 0600 "$home/.ssh/authorized_keys"

  cat > "$home/.ssh/config" <<EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF
  chmod 600 "$home/.ssh/config"

  if [ ! -z "$privkey" ] ; then
    aws ssm get-parameter --name "$privkey" --with-decryption \
      --query Parameter.Value --output text > "$home/.ssh/id_rsa"

    chmod 400 "$home/.ssh/id_rsa"
  fi
}

create_group crmsAFT 9011
create_user crmsAFT crmsAFT 9011 $ssm_pubkey "" "/opt/crmsAFT"
lusermod ctmagentv9 -g 9011
luseradd ctmuser -d /opt/ctmuser -g 9011

#Set the password of users to never expire
passwd -x 99999 ctmagentv9
passwd -x 99999 ctmuser

echo $support_topic_arn > /opt/crmsAFT/.support_topic_arn
chmod 666 /opt/crmsAFT/.support_topic_arn
passwd -d crmsAFT
passwd -l crmsAFT
passwd -x 99999 crmsAFT

echo "3. disable sshd"
#This function is copied from: https://github.aus.thenational.com/ONCILLA/oncilla-data/blob/master/cloudformation/userdata/batch.xml.template
sed -i 's/Subsystem sftp.*/#&/' /etc/ssh/sshd_config
systemctl restart sshd

echo "4. Configure sshd for aft"
sed 's/#Port.*/Port 8022/' /etc/ssh/sshd_config |tee /etc/ssh/sshd_aft_config

#Replace subsystem statement to ensure sftp is enabled
sed -i '/Subsystem sftp/d' /etc/ssh/sshd_aft_config
sed -i '/no subsystems/a Subsystem sftp /usr/libexec/openssh/sftp-server' /etc/ssh/sshd_aft_config

#Replace old Cipher with the new one 
sed '/^Ciphers/d' /etc/ssh/sshd_aft_config
sed -i '/# Ciphers and keying/a Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,arcfour' /etc/ssh/sshd_aft_config

echo "" |tee -a /etc/ssh/sshd_aft_config
echo "Match User crmsAFT
  ForceCommand internal-sftp
  AllowTcpForwarding no
  ChrootDirectory /extract
" | tee -a /etc/ssh/sshd_aft_config

sed -E '
    s/(Description=.*)/\1 (AFT)/
    s!(ExecStart=.*)!\1 -f /etc/ssh/sshd_aft_config!
 ' /usr/lib/systemd/system/sshd.service | tee /usr/lib/systemd/system/sshd-aft.service

#Start sshd-aft
systemctl enable sshd-aft --now
systemctl start sshd-aft

#It's recommended by AWS to turn off ID mapper
#https://docs.aws.amazon.com/efs/latest/ug/accessing-fs-nfs-permissions.html#accessing-fs-nfs-permissions-uid-gid
service rpcidmapd status
sudo service rpcidmapd stop

#Create user for tower scp
#create_group towerscp 9011
luseradd towerscp -d /opt/towerscp -g 9011
mkdir -p "/opt/towerscp/.ssh"
aws ssm get-parameter --name $twr_scpkey --with-decryption --query Parameter.Value --output text  > "/opt/towerscp/.ssh/authorized_keys"
chown -R "towerscp:crmsAFT" "/opt/towerscp"
chmod 0744 "/opt/towerscp"
chmod 0700 "/opt/towerscp/.ssh"
chmod 0600 "/opt/towerscp/.ssh/authorized_keys"
#create_user towerscp crmsAFT 9011 $twr_scpkey "" "/opt/towerscp"
#Set the password date to never expire
passwd -x 99999 towerscp

echo "5. Turn on CloudWatch Agent"
#1. Fix proxy server
echo '[proxy]
   http_proxy = "http://forwardproxy:3128"
   https_proxy = "http://forwardproxy:3128"
   no_proxy = "localhost,169.254.169.254,hip.ext.national.com.au"'> /opt/aws/amazon-cloudwatch-agent/etc/common-config.toml

#2. Start agent using configuration file
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/Cloudwatch_EC2_config.json -s
