#!/bin/bash

# Fetching require packages to install NGINX server using openssl-devel gcc
sudo yum install openssl-devel gcc

# directory for NGINX Server
sudo mkdir  -p /web/nginx
sudo mkdir /web/nginx/modules
sudo mkdir  /web/nginx/run
sudo cd /web/nginx/

sudo mv /tmp/nginx-1.20.1.tar.gz .
#ls -lrt

sudo mkdir binaries 
sudo mv nginx-1.20.1/* binaries/
sudo rm  -rf nginx-1.20.1/
# pwd
# ls  -lrt

sudo ./configure --prefix=/web/nginx --modules-path=/web/nginx/modules --with-http_ssl_module  --without-http_fastcgi_module --without-http_uwsgi_module --without-http_grpc_module --without-http_scgi_module --without-mail_imap_module --without-mail_pop3_module 
sudo make
sudo make  install

# pwd /web/nginx
sudo rm  -rf binaries/
sudo vi /web/nginx/conf/nginx.conf

sudo cat /usr/lib/systemd/system/nginx.service
sudo systemctl enable nginx.service
sudo systemctl start  nginx