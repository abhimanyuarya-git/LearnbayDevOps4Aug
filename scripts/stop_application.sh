#!/bin/bash

# Stop the application gracefully
if command -v pm2 &> /dev/null; then
    pm2 stop myapp || true
    pm2 delete myapp || true
fi

# Kill any remaining Node.js processes
pkill -f "node.*myapp" || true

echo "Application stopped successfully"