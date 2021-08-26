source ~ec2-user/.bash_profile

smb_user=$1
smb_pwd=$(/tmp/crms_decrypt $(aws ssm get-parameter --name $2 --with-decryption --query Parameter.Value --output text))
yum install samba -y
luseradd $smb_user
if [ $? != 0 ]; then
	echo "Error: unable to create user $smb_user"
	exit 1
fi
mkdir -p /extract/${smb_user}_share
chmod -R 777 /extract/${smb_user}_share/
chown -R $smb_user /extract/${smb_user}_share
chgrp -R $smb_user /extract/${smb_user}_share

echo "

[$smb_user]
	comment=$smb_user
	path=/extract/${smb_user}_share
	browseable=yes
	writable=yes
	create mode=0777
	directory mode=0777
	share mode=yes
	guest ok=no
	valid users=$smb_user
" >> /etc/samba/smb.conf

service smb restart
service nmb restart
systemctl enable smb
systemctl enable nmb

echo "(echo "$smb_pwd"; echo "$smb_pwd") | smbpasswd -a $smb_user" > /tmp/defered_action.sh
