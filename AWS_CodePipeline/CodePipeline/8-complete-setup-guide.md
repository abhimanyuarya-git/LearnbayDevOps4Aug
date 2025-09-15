# Complete AWS CodePipeline Setup Guide

## Quick Start Commands

### 1. Replace Account ID and Region
```bash
# Set your AWS account ID and region
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1

# Replace placeholders in all configuration files
find . -name "*.json" -o -name "*.md" -o -name "*.yml" | xargs sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g"
find . -name "*.json" -o -name "*.md" -o -name "*.yml" | xargs sed -i "s/us-east-1/$AWS_REGION/g"
```

### 2. Execute Setup in Order
```bash
# Step 1: GitHub Setup
bash -c "$(cat 1-github-setup.md | grep -A 20 '```bash' | grep -v '```')"

# Step 2: CodeArtifact  
bash -c "$(cat 2-codeartifact-setup.md | grep -A 20 '```bash' | grep -v '```')"

# Step 3: CodeBuild
bash -c "$(cat 3-codebuild-setup.md | grep -A 20 '```bash' | grep -v '```')"

# Step 4: CodeDeploy
bash -c "$(cat 4-codedeploy-setup.md | grep -A 20 '```bash' | grep -v '```')"

# Step 5: CodePipeline
bash -c "$(cat 5-codepipeline-setup.md | grep -A 20 '```bash' | grep -v '```')"

# Step 6: CodeGuru
bash -c "$(cat 6-codeguru-setup.md | grep -A 20 '```bash' | grep -v '```')"

# Step 7: CodeStar
bash -c "$(cat 7-codestar-setup.md | grep -A 20 '```bash' | grep -v '```')"
```

## Architecture Flow

1. **Developer pushes code** → GitHub
2. **CodePipeline triggers** → Detects changes
3. **CodeBuild runs** → Tests, builds, packages
4. **CodeGuru reviews** → Automated code analysis
5. **CodeDeploy deploys** → To EC2 instances
6. **CodeStar manages** → Project oversight
7. **CodeArtifact stores** → Package dependencies

## Key Benefits

- **Automated CI/CD**: Complete automation from code to deployment
- **Code Quality**: CodeGuru provides ML-powered reviews
- **Artifact Management**: CodeArtifact for dependency management
- **Monitoring**: Built-in monitoring and logging
- **Team Collaboration**: CodeStar for project management

## Troubleshooting

### Common Issues
1. **IAM Permissions**: Ensure all service roles have proper permissions
2. **S3 Bucket Names**: Must be globally unique
3. **EC2 Security Groups**: Allow necessary ports (3000, 22, 80)
4. **CodeDeploy Agent**: Must be installed and running on EC2

### Verification Commands
```bash
# Check pipeline status
aws codepipeline get-pipeline-state --name MyApp-Pipeline

# Check CodeBuild logs
aws logs describe-log-groups --log-group-name-prefix /aws/codebuild/my-app-build

# Check CodeDeploy status
aws deploy list-deployments --application-name MyApp

# Test application
curl http://your-ec2-public-ip:3000/health
```

## Next Steps

1. Set up monitoring with CloudWatch
2. Configure notifications with SNS
3. Add more deployment environments (staging, production)
4. Implement blue-green deployments
5. Add security scanning with Inspector