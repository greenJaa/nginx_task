#!/bin/bash
#########################################
# Developed by: Oleg Ischouk
# Purpose: Nginx Virtual Host Setup Script
# Date: 28/02/2025
# Version: 1.0.1
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

# Check virtual host status
if [[ -f /etc/nginx/sites-available/default && $VIRTUAL_HOSTS_COUNT -eq 1 ]]; then
    echo "nginx virtual host is configured with default configuration."
elif [[ $VIRTUAL_HOSTS_COUNT -eq 0 ]]; then
    echo "nginx virtual host is not configured."
else
    echo "nginx virtual host is already configured."
fi

# Ask for the host name
echo "Please enter host name:"
read -r HOST_NAME
echo "Configuring virtual host for $HOST_NAME"
export HOST_NAME
#PORT=${PORT:-8080}
PORT=8080

export PORT
# Create the website directory
sudo mkdir -p "/var/www/$HOST_NAME"

# Generate the nginx config from template
envsubst '${HOST_NAME}${PORT}' < virtual_host_settings.tmpl | sudo tee /etc/nginx/sites-available/$HOST_NAME > /dev/null

# Create a symlink to enable the site if it doesn't exist
if [[ ! -L /etc/nginx/sites-enabled/$HOST_NAME ]]; then
    sudo ln -s /etc/nginx/sites-available/$HOST_NAME /etc/nginx/sites-enabled/
fi

# Set proper permissions for the web root directory
sudo chown -R www-data:www-data "/var/www/$HOST_NAME"

# Ensure Nginx configuration is valid before restarting
sudo nginx -s reload || sudo nginx

# Add entry to /etc/hosts (for local testing) only if not already present
if [[ ! $(< /etc/hosts) == *" $HOST_NAME"* ]]; then
    echo "127.0.0.1 $HOST_NAME" | sudo tee -a /etc/hosts
fi

# Copy default index.html page
if [[ -f ./index.html ]]; then
    sudo cp ./index.html "/var/www/$HOST_NAME/index.html"
fi

# Test if the virtual host is working
curl -I http://$HOST_NAME:$PORT
