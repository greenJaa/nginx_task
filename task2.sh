#!/bin/bash
#########################################
# Developed by: Oleg Ischouk
# Purpose: Nginx Virtual Host Setup Script
# Date: 28/02/2025
# Version: 1.0.0
set -o errexit
#set -o pipefail
#set -x
########################################

# Check if nginx is installed
if ! command -v nginx > /dev/null; then
    echo "nginx is not installed... installing"
    sudo apt update && sudo apt install -y nginx
else
    echo "nginx is installed"
fi

# Check nginx installation success
if ! command -v nginx > /dev/null; then
    echo "nginx package installation failed"
    exit 1
fi

# Count the number of virtual hosts configured
VIRTUAL_HOSTS_COUNT=$(ls -1 /etc/nginx/sites-available/ | wc -l)
echo "**************"
echo "$VIRTUAL_HOSTS_COUNT"
echo "**************"

# Check if default configuration exists or if virtual hosts are configured
if [ -f /etc/nginx/sites-available/default ] && [ "$VIRTUAL_HOSTS_COUNT" -eq 1 ]; then
    echo "nginx virtual host is configured with default configuration."
else
    if [ "$VIRTUAL_HOSTS_COUNT" -eq 0 ]; then
        echo "nginx virtual host is not configured."
    else
        echo "nginx virtual host is already configured."
        #exit 0
    fi
fi

# Ask for the host name
echo "Please enter host name:"
read -r HOST_NAME
echo "Configuring virtual host for $HOST_NAME"

# Create the website directory
sudo mkdir -p "/var/www/$HOST_NAME"

# Create the server block config file
#sudo tee /etc/nginx/sites-available/$HOST_NAME > /dev/null < virtual_host_settings.tmpl
#envsubst < virtual_host_settings.tmpl | sudo tee /etc/nginx/sites-available/$HOST_NAME
envsubst '${HOST_NAME}' < virtual_host_settings.tmpl | sudo tee /etc/nginx/sites-available/$HOST_NAME > /dev/null

#sudo tee /etc/nginx/sites-available/$HOST_NAME > /dev/null <<EOF
#server {
#    listen 80;
#    listen [::]:80;
#    server_name $HOST_NAME;
#    root /var/www/$HOST_NAME;
#    index index.html index.htm index.nginx-debian.html;
#
#   location / {
#       # First attempt to serve request as file, then
#       # as directory, then fall back to displaying a 404.
#        try_files \$uri \$uri/ =404;
#    }
#}
#EOF

# Create a symlink to enable the site
if [ ! -L /etc/nginx/sites-enabled/$HOST_NAME ]; then
    sudo ln -s /etc/nginx/sites-available/$HOST_NAME /etc/nginx/sites-enabled/
fi

# Set proper permissions for the web root directory
sudo chown -R www-data:www-data "/var/www/$HOST_NAME"

# Ensure Nginx configuration is valid before restarting
#sudo nginx -t && sudo systemctl restart nginx
sudo nginx -s reload || sudo nginx


# Add entry to /etc/hosts (for local testing)
echo "127.0.0.1 $HOST_NAME" | sudo tee -a /etc/hosts

# Test if the virtual host is working
curl -I http://$HOST_NAME
