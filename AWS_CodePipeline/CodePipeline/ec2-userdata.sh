#!/bin/bash
yum update -y

# Install CodeDeploy agent
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install PM2 globally
npm install -g pm2

# Create application directory
mkdir -p /var/www/html/myapp
chown ec2-user:ec2-user /var/www/html/myapp

# Start CodeDeploy agent
service codedeploy-agent start
chkconfig codedeploy-agent on

# Configure PM2 to start on boot
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "EC2 instance setup completed"