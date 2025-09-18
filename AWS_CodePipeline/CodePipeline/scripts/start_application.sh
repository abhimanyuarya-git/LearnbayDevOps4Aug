#!/bin/bash
set -e

# Navigate to application directory
cd /var/www/html/myapp

# Ensure PM2 is available
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# Stop any existing application
pm2 stop myapp || true
pm2 delete myapp || true

# Start the application (check for both app.js and src/app.js)
if [ -f "app.js" ]; then
    pm2 start app.js --name myapp
elif [ -f "src/app.js" ]; then
    pm2 start src/app.js --name myapp
else
    echo "Error: No app.js found in current directory or src/ directory"
    exit 1
fi

pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "Application started successfully"