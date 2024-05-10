#!/bin/bash

# Update system packages
sudo dnf update -y

# Install nginx package
sudo dnf install -y nginx

# Start nginx service
sudo systemctl start nginx

# Enable nginx service to start on boot
sudo systemctl enable nginx

# Configure nginx for a basic website
sudo tee /etc/nginx/conf.d/mywebsite.conf > /dev/null <<EOF
server {
    listen 80;
    server_name geminiarchive-app-tst.gem.aws.odev.com.au;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Create a sample index.html file
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to my Gemini website</title>
</head>
<body>
    <h1>Hello, world!</h1>
    <p>This is a sample website hosted by nginx on Red Hat Enterprise Linux 8.</p>
</body>
</html>
EOF

# Set permissions for the website directory
sudo chmod -R 755 /var/www/html

# Reload nginx to apply changes
sudo systemctl reload nginx

# Check nginx status
sudo systemctl status nginx
