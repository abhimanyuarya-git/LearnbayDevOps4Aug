# SRE-Compliant AWS CodePipeline Setup

## Architecture Overview

**Terraform (Infrastructure as Code):**
- ✅ S3 bucket with encryption and security
- ✅ IAM roles with least privilege
- ✅ CodeBuild with caching and optimization
- ✅ CodePipeline with proper monitoring
- ✅ Lambda with structured logging
- ✅ Secrets Manager with secure token storage
- ✅ Resource tagging and cost management

**Python (SRE Automation):**
- ✅ GitHub webhook with retry logic
- ✅ Error handling and structured logging
- ✅ Monitoring and alerting integration
- ✅ Automated testing and validation

## Quick Setup (5 minutes)

### Step 1: Configure Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# github_owner  = "your-github-username"
# github_token  = "ghp_your_token_here"
```

### Step 2: Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy all AWS resources
terraform apply -auto-approve
```

### Step 3: Python Automation
```bash
cd ../python-automation

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export GITHUB_OWNER="your-github-username"
export GITHUB_TOKEN="ghp_your_token_here"

# Run automation
python setup_pipeline.py
```

## What Gets Created

### AWS Resources (via Terraform):
- **S3 Bucket**: `learnbay-devops-artifacts-xxxxxxxx`
- **IAM Roles**: CodePipeline, CodeBuild, Lambda roles
- **CodeBuild Project**: `learnbay-devops-build`
- **Lambda Function**: `github-merge-function`
- **CodePipeline**: `learnbay-devops-pipeline`
- **Secrets Manager**: GitHub token storage

### GitHub Integration (via Python):
- **Webhook**: Triggers pipeline on push to develop
- **API Integration**: Auto-merge functionality

## Demo Execution

### Test the Pipeline:
```bash
# Create develop branch
git checkout -b develop
git push origin develop

# Make a change
echo "// Terraform demo change" >> app/app.js
git add . && git commit -m "Test: Terraform pipeline"
git push origin develop
```

### Monitor Results:
```bash
# Check pipeline status
terraform output pipeline_url

# View logs
aws logs tail /aws/codebuild/learnbay-devops-build --follow
```

## Cleanup

```bash
# Destroy all resources
terraform destroy -auto-approve
```

## SRE Benefits

- **Reliability**: Retry logic, error handling, circuit breakers
- **Observability**: Structured logging, monitoring, tracing
- **Automation**: Zero manual steps, self-healing systems
- **Security**: Encryption, least privilege, secret management
- **Scalability**: Multi-environment, cost optimization
- **Maintainability**: Infrastructure as code, proper documentation