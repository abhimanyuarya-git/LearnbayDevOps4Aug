#!/bin/bash

# Variables
BUCKET_NAME="learnbay-codedeploy-bucket-$(date +%s)"
APP_NAME="learnbay-app"
DEPLOYMENT_GROUP="learnbay-app-DeploymentGroup"

echo "Creating S3 deployment for learnbay-app..."

# Create S3 bucket
aws s3 mb s3://$BUCKET_NAME

# Create deployment bundle
zip -r learnbay-app.zip . -x "*.git*" "node_modules/*" "*.DS_Store*" "deploy-s3.sh"

# Upload to S3
aws s3 cp learnbay-app.zip s3://$BUCKET_NAME/

# Create deployment
DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name $APP_NAME \
    --deployment-group-name $DEPLOYMENT_GROUP \
    --s3-location bucket=$BUCKET_NAME,key=learnbay-app.zip,bundleType=zip \
    --query 'deploymentId' --output text)

echo "Deployment created: $DEPLOYMENT_ID"
echo "Monitor with: aws deploy get-deployment --deployment-id $DEPLOYMENT_ID"

# Clean up local zip
rm learnbay-app.zip

echo "S3 bucket: $BUCKET_NAME"