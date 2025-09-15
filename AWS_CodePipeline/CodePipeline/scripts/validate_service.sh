#!/bin/bash
set -e

# Wait for application to start
sleep 10

# Check if application is running
if pm2 list | grep -q "myapp.*online"; then
    echo "Application is running successfully"
    
    # Test HTTP endpoint
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        echo "Health check passed"
        exit 0
    else
        echo "Health check failed"
        exit 1
    fi
else
    echo "Application is not running"
    exit 1
fi