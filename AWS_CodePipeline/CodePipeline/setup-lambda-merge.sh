#!/bin/bash

# Setup Lambda function for GitHub auto-merge
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_OWNER="your-github-username"  # Replace with your GitHub username
GITHUB_REPO="LearnbayDevOps4Aug"

echo "Setting up Lambda function for auto-merge..."

# Create Lambda execution role
aws iam create-role \
    --role-name GitHubMergeLambdaRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

# Attach policies
aws iam attach-role-policy \
    --role-name GitHubMergeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
    --role-name GitHubMergeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite

# Create deployment package
zip lambda-merge.zip lambda-merge-function.py

# Create Lambda function
aws lambda create-function \
    --function-name github-merge-function \
    --runtime python3.9 \
    --role arn:aws:iam::$ACCOUNT_ID:role/GitHubMergeLambdaRole \
    --handler lambda-merge-function.lambda_handler \
    --zip-file fileb://lambda-merge.zip \
    --environment Variables="{GITHUB_OWNER=$GITHUB_OWNER,GITHUB_REPO=$GITHUB_REPO}" \
    --timeout 30

echo "Lambda function created successfully!"
echo "Function ARN: arn:aws:lambda:us-east-1:$ACCOUNT_ID:function:github-merge-function"