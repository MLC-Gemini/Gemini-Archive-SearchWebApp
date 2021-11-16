#!/bin/bash

# Create webapp user 
sudo luseradd webapp -d /opt/webapp 
echo "webapp         ALL=(ALL)       NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

# Directory for Gemini web application
sudo mkdir -p /var/www
sudo mkdir /var/www/geminiweb
sudo chmod -R 775 /var/www/geminiweb/
cd /var/www/geminiweb

# Copy ASP.NET core self-contained published file in web directory, change permisson and ownership and making file self-executable.
sudo mv /tmp/Published/* .
sudo chown webapp:webapp GeminiSearchWebApp
sudo chmod 775 GeminiSearchWebApp
sudo chmod +x GeminiSearchWebApp

# Creating service configuration file for environment (Development, Producation)
cd /etc/systemd/system/
sudo mv /tmp/kestrel-geminiweb.service .

# Starting and checking the kestral service status.
sudo systemctl start kestrel-geminiweb.service
sudo systemctl status kestrel-geminiweb.service
#curl localhost:5000

# Enabling service so it will run automatically af¬ter start of the operating system.
sudo systemctl enable kestrel-geminiweb.service

# Install require packages for NGINX server using "openssl-devel gcc"
sudo yum -y install openssl-devel gcc -q -y
#sudo yum -y install openssl-devel gcc
#rpm -qa|egrep 'openssl-devel|pcre|zlib'

# Directory for NGINX Server
sudo mkdir -p /web/nginx
sudo mkdir /web/nginx/modules
sudo mkdir /web/nginx/run
cd /web/nginx/

sudo mv /tmp/nginx-1.20.1.tar.gz .
#sudo tar -xzvf nginx-1.20.1.tar.gz with output below command for skipping output (-v without verbose)
sudo tar -zxf nginx-1.20.1.tar.gz
#ls -lrt

sudo mkdir binaries 
sudo mv nginx-1.20.1/* binaries/

sudo rm -rf nginx-1.20.1/
sudo rm -rf nginx-1.20.1.tar.gz

cd binaries/
# pwd > /web/nginx/binaries
# ls  -lrt

sudo ./configure --prefix=/web/nginx --modules-path=/web/nginx/modules --with-http_ssl_module  --without-http_fastcgi_module --without-http_uwsgi_module --without-http_grpc_module --without-http_scgi_module --without-mail_imap_module --without-mail_pop3_module > /dev/null
sudo make > /dev/null
sudo make install > /dev/null

# pwd > /web/nginx
sudo rm -rf binaries/

# SSl certificate 
cd /web/nginx/
sudo mkdir -p /web/nginx/ssl-cert
sudo chown root:root ssl-cert
sudo chmod -R 600 ssl-cert
cd /web/nginx/ssl-cert
sudo mv /tmp/geminiarchive-app.pem .
sudo mv /tmp/geminiarchive-app.key .

#sudo vi /web/nginx/conf/nginx.conf
cd /web/nginx/conf/
sudo mv nginx.conf nginx.Bk-Original-conf
sudo mv /tmp/nginx.conf .

#sudo cat /usr/lib/systemd/system/nginx.service
cd /usr/lib/systemd/system/
sudo mv nginx.service nginx.Bk-Original-service
sudo mv /tmp/nginx.service .

sudo systemctl enable nginx.service
sudo systemctl start nginx
sudo systemctl status nginx

#Add scheduled patching code
crontab << EOF
00 18 8-14 * 7 echo "START patching" >> /tmp/weekly-patching.log ; curl https://hip.ext.national.com.au/hip_upgrade.sh | bash -s -- -a latest ; echo "FINISH patching"
EOF
