#!/bin/bash
set -e

# Install Node.js and npm if not already installed
if ! command -v node &> /dev/null; then
    # For Amazon Linux 2
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
fi

# Navigate to application directory
cd /var/www/html/myapp

# Install application dependencies
if [ -f "package.json" ]; then
    npm install --production
else
    echo "No package.json found, skipping npm install"
fi

# Install PM2 globally if not installed
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# Set proper permissions
chown -R ec2-user:ec2-user /var/www/html/myapp
chmod +x /var/www/html/myapp/scripts/*.sh 2>/dev/null || true

echo "Dependencies installed successfully"