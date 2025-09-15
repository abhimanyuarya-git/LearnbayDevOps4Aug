#!/bin/bash
set -e

# Install Node.js and npm if not already installed
if ! command -v node &> /dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
fi

# Navigate to application directory
cd /var/www/html/myapp

# Install application dependencies
npm install --production

# Set proper permissions
chown -R ec2-user:ec2-user /var/www/html/myapp
chmod +x /var/www/html/myapp/scripts/*.sh

echo "Dependencies installed successfully"