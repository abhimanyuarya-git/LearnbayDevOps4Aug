# CodeDeploy Deployment Guide

## Prerequisites Setup

### 1. EC2 Instance Setup
- Launch an Amazon Linux 2 EC2 instance
- Use the `ec2-userdata.sh` script as user data during launch
- Ensure the instance has the following IAM role permissions:
  - `AmazonEC2RoleforAWSCodeDeploy`
  - `CloudWatchAgentServerPolicy`

### 2. CodeDeploy Application Setup
```bash
# Create CodeDeploy application
aws deploy create-application \
    --application-name learnbay-app \
    --compute-platform Server

# Create deployment group
aws deploy create-deployment-group \
    --application-name learnbay-app \
    --deployment-group-name learnbay-app-DeploymentGroup \
    --service-role-arn arn:aws:iam::YOUR-ACCOUNT:role/CodeDeployServiceRole \
    --ec2-tag-filters Key=Name,Value=MyAppServer,Type=KEY_AND_VALUE
```

### 3. Required IAM Roles

#### CodeDeploy Service Role
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

#### EC2 Instance Profile
Attach these policies:
- `AmazonEC2RoleforAWSCodeDeploy`
- `CloudWatchAgentServerPolicy`

## Deployment Steps

### 1. Prepare Your Code
Ensure your repository has:
- `appspec.yml` (✓ Created)
- `buildspec.yml` (✓ Created)
- `package.json` (✓ Created)
- `scripts/` directory with deployment scripts (✓ Updated)

### 2. Create Deployment
```bash
# Create deployment
aws deploy create-deployment \
    --application-name learnbay-app \
    --deployment-group-name learnbay-app-DeploymentGroup \
    --s3-location bucket=YOUR-BUCKET,key=learnbay-app.zip,bundleType=zip
```

### 3. Monitor Deployment
```bash
# Check deployment status
aws deploy get-deployment --deployment-id YOUR-DEPLOYMENT-ID

# View deployment logs on EC2
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

## Troubleshooting

### Common Issues:
1. **CodeDeploy agent not running**: Check `sudo service codedeploy-agent status`
2. **Permission errors**: Ensure proper file permissions in appspec.yml
3. **Application not starting**: Check PM2 logs with `pm2 logs myapp`
4. **Health check failing**: Verify application is listening on port 3000

### Debug Commands:
```bash
# Check application status
pm2 status
pm2 logs myapp

# Check CodeDeploy agent
sudo service codedeploy-agent status
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log

# Test application manually
curl http://localhost:3000/health
```

## File Structure
```
CodePipeline/
├── appspec.yml          # CodeDeploy configuration
├── buildspec.yml        # CodeBuild configuration  
├── package.json         # Node.js dependencies
├── app.js              # Main application file
└── scripts/
    ├── install_dependencies.sh
    ├── start_application.sh
    ├── stop_application.sh
    └── validate_service.sh
```