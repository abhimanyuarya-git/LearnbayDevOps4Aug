#!/bin/bash
set -e

# Navigate to application directory
cd /var/www/html/myapp

# Start the application using PM2 (process manager)
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

# Stop any existing application
pm2 stop myapp || true
pm2 delete myapp || true

# Start the application
pm2 start src/app.js --name myapp
pm2 save
pm2 startup

echo "Application started successfully"