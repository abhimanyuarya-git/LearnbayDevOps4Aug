#!/bin/bash

# Variables - UPDATE THESE
GITHUB_USERNAME="your-github-username"
REPO_NAME="your-repo-name"
GITHUB_TOKEN="your-github-token"
KEY_PAIR="your-key-pair"
SECURITY_GROUP="sg-xxxxxxxxx"
BUCKET_NAME="your-codedeploy-bucket-$(date +%s)"

echo "Setting up AWS CodePipeline with CodeDeploy..."

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create S3 bucket
aws s3 mb s3://$BUCKET_NAME

# Create CodeDeploy application
aws deploy create-application --application-name learnbay-app --compute-platform Server

# Create deployment group
aws deploy create-deployment-group \
    --application-name learnbay-app \
    --deployment-group-name learnbay-app-DeploymentGroup \
    --service-role-arn arn:aws:iam::${ACCOUNT_ID}:role/CodeDeployServiceRole \
    --ec2-tag-filters Key=Name,Value=MyAppServer,Type=KEY_AND_VALUE

# Launch EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t2.micro \
    --key-name $KEY_PAIR \
    --security-group-ids $SECURITY_GROUP \
    --iam-instance-profile Name=EC2CodeDeployInstanceProfile \
    --user-data file://ec2-userdata.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=MyAppServer}]" \
    --query 'Instances[0].InstanceId' --output text)

echo "EC2 Instance created: $INSTANCE_ID"
echo "S3 Bucket created: $BUCKET_NAME"
echo "Setup complete! Update the variables in this script and run again."