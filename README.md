# Nginx Virtual Host Setup Script

This script automates the process of setting up a new virtual host on an Nginx server on port 8080

## Features:
- Installs Nginx if not already installed.
- Configures a new virtual host with a specified domain.
- Creates necessary directories and configuration files.
- Adds the domain to `/etc/hosts` for local testing.
- Restarts Nginx after the configuration is set.

## Usage:

1. Clone the repository.
2. Run the script with `sudo`:
   ```bash
   sudo ./task2.sh
