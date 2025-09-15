#!/bin/bash

# Complete deployment script - Terraform + Python automation

set -e

echo "🚀 AWS CodePipeline Deployment with Terraform + Python"

# Check prerequisites
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not installed"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not installed"
    exit 1
fi

# Get user inputs
read -p "Enter your GitHub username: " GITHUB_OWNER
read -s -p "Enter your GitHub token: " GITHUB_TOKEN
echo

export GITHUB_OWNER
export GITHUB_TOKEN

# Step 1: Deploy infrastructure with Terraform
echo "📦 Deploying AWS infrastructure with Terraform..."
cd terraform

# Create terraform.tfvars
cat > terraform.tfvars << EOF
github_owner = "$GITHUB_OWNER"
github_token = "$GITHUB_TOKEN"
EOF

# Deploy
terraform init
terraform plan
terraform apply -auto-approve

echo "✅ Infrastructure deployed successfully"

# Step 2: Run Python automation
echo "🐍 Running Python automation..."
cd ../python-automation

# Install dependencies
pip3 install -r requirements.txt

# Run automation
python3 setup_pipeline.py

echo "✅ Pipeline setup completed!"

# Step 3: Display results
cd ../terraform
echo "📋 Deployment Summary:"
echo "Pipeline URL: $(terraform output -raw pipeline_url)"
echo "S3 Bucket: $(terraform output -raw s3_bucket_name)"
echo "Lambda Function: $(terraform output -raw lambda_function_name)"

echo "🎉 Ready for demo! Push to develop branch to trigger pipeline."