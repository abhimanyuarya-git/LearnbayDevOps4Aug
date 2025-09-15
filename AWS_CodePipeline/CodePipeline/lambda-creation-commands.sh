#!/bin/bash

# Lambda Function Creation - Step by Step Commands

echo "=== Lambda Function Creation Process ==="

# Step 1: Create IAM Role for Lambda
echo "1. Creating IAM Role..."
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

# Step 2: Attach Required Policies
echo "2. Attaching policies..."
aws iam attach-role-policy \
    --role-name GitHubMergeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
    --role-name GitHubMergeLambdaRole \
    --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite

# Step 3: Package Lambda Code
echo "3. Creating deployment package..."
zip lambda-merge.zip lambda-merge-function.py

# Step 4: Create Lambda Function
echo "4. Creating Lambda function..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_OWNER="your-github-username"  # Replace with actual username

aws lambda create-function \
    --function-name github-merge-function \
    --runtime python3.9 \
    --role arn:aws:iam::$ACCOUNT_ID:role/GitHubMergeLambdaRole \
    --handler lambda-merge-function.lambda_handler \
    --zip-file fileb://lambda-merge.zip \
    --environment Variables="{GITHUB_OWNER=$GITHUB_OWNER,GITHUB_REPO=LearnbayDevOps4Aug}" \
    --timeout 30 \
    --description "Auto-merge develop to main after successful pipeline"

echo "5. Lambda function created successfully!"

# Step 5: Verify Lambda Function
echo "6. Verifying Lambda function..."
aws lambda get-function --function-name github-merge-function

echo "=== Lambda Function Ready for Pipeline Integration ==="