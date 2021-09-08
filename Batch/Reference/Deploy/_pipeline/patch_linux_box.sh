#_pipeline/patch_linux_box.sh  IP Key_file
ip=$1
key_file=$2
ssh -i $key_file ec2-user@$ip 'sudo -E pip uninstall urllib3 -y;curl https://hip.ext.national.com.au/hip_upgrade.sh | sudo bash -s -- -a latest;sudo -E pip install urllib3 --force-reinstall;sudo shutdown -r'
