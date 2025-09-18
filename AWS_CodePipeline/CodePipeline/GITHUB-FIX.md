# GitHub Source Configuration Fix

## Problem
CodeDeploy is trying to access an invalid GitHub URL that includes the full GitHub URL in the API path.

## Solution

### Option 1: Use S3 Source (Recommended)
Instead of GitHub, use S3 as source:

```bash
# Create deployment bundle
cd /Users/abhi/codeclub/LearnbayDevOps4Aug/AWS_CodePipeline/CodePipeline
zip -r learnbay-app.zip . -x "*.git*" "node_modules/*"

# Upload to S3
aws s3 cp learnbay-app.zip s3://your-bucket-name/

# Create deployment
aws deploy create-deployment \
    --application-name learnbay-app \
    --deployment-group-name learnbay-app-DeploymentGroup \
    --s3-location bucket=your-bucket-name,key=learnbay-app.zip,bundleType=zip
```

### Option 2: Fix GitHub Configuration
Update your CodePipeline source configuration:

```json
{
  "name": "Source",
  "actionTypeId": {
    "category": "Source",
    "owner": "ThirdParty",
    "provider": "GitHub",
    "version": "1"
  },
  "configuration": {
    "Owner": "abhimanyuarya-git",
    "Repo": "LearnbayDevOps4Aug",
    "Branch": "main",
    "OAuthToken": "your-github-token"
  },
  "outputArtifacts": [{"name": "SourceOutput"}]
}
```

### Option 3: Use CodeCommit (AWS Native)
```bash
# Create CodeCommit repository
aws codecommit create-repository --repository-name learnbay-app

# Clone and push your code
git clone https://git-codecommit.region.amazonaws.com/v1/repos/learnbay-app
cp -r /Users/abhi/codeclub/LearnbayDevOps4Aug/AWS_CodePipeline/CodePipeline/* learnbay-app/
cd learnbay-app
git add .
git commit -m "Initial commit"
git push origin main
```

## Quick Fix Command
```bash
# Create and upload deployment bundle
cd /Users/abhi/codeclub/LearnbayDevOps4Aug/AWS_CodePipeline/CodePipeline
zip -r learnbay-app.zip . -x "*.git*" "node_modules/*" "*.DS_Store*"
aws s3 cp learnbay-app.zip s3://your-codedeploy-bucket/
```