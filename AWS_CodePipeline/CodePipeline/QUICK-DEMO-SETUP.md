# Quick Demo Setup (10 Minutes)

## Prerequisites
- AWS CLI configured
- GitHub repository access
- Your GitHub username

## Step 1: Environment Setup (2 minutes)
```bash
cd /Users/abhi/codeclub/LearnbayDevOps4Aug/AWS_CodePipeline/CodePipeline

# Set your GitHub username
export GITHUB_USERNAME="your-actual-github-username"
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

## Step 2: Create GitHub Token & Store in AWS (1 minute)
```bash
# Replace YOUR_TOKEN with actual GitHub token
aws secretsmanager create-secret \
    --name "github-token" \
    --secret-string '{"token":"YOUR_GITHUB_TOKEN_HERE"}'
```

## Step 3: Create S3 Bucket (1 minute)
```bash
BUCKET_NAME="codepipeline-demo-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME
```

## Step 4: Setup Lambda for Auto-Merge (2 minutes)
```bash
# Update GitHub username in setup script
sed -i "s/your-github-username/$GITHUB_USERNAME/g" setup-lambda-merge.sh

# Run setup
./setup-lambda-merge.sh
```

## Step 5: Create IAM Roles (2 minutes)
```bash
# CodePipeline Role
aws iam create-role --role-name CodePipelineServiceRole --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "codepipeline.amazonaws.com"},
        "Action": "sts:AssumeRole"
    }]
}'

aws iam attach-role-policy --role-name CodePipelineServiceRole --policy-arn arn:aws:iam::aws:policy/AWSCodePipelineFullAccess

# CodeBuild Role
aws iam create-role --role-name CodeBuildServiceRole --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "codebuild.amazonaws.com"},
        "Action": "sts:AssumeRole"
    }]
}'

aws iam attach-role-policy --role-name CodeBuildServiceRole --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
```

## Step 6: Create CodeBuild Project (1 minute)
```bash
aws codebuild create-project \
    --name "LearnbayDevOps-Build" \
    --source type=GITHUB,location=https://github.com/$GITHUB_USERNAME/LearnbayDevOps4Aug.git \
    --artifacts type=S3,location=$BUCKET_NAME/builds \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:4.0,computeType=BUILD_GENERAL1_MEDIUM \
    --service-role arn:aws:iam::$ACCOUNT_ID:role/CodeBuildServiceRole
```

## Step 7: Create Pipeline (1 minute)
```bash
cat > pipeline.json << EOF
{
  "pipeline": {
    "name": "LearnbayDevOps-Pipeline",
    "roleArn": "arn:aws:iam::$ACCOUNT_ID:role/CodePipelineServiceRole",
    "artifactStore": {"type": "S3", "location": "$BUCKET_NAME"},
    "stages": [
      {
        "name": "Source",
        "actions": [{
          "name": "SourceAction",
          "actionTypeId": {"category": "Source", "owner": "ThirdParty", "provider": "GitHub", "version": "1"},
          "configuration": {
            "Owner": "$GITHUB_USERNAME",
            "Repo": "LearnbayDevOps4Aug",
            "Branch": "develop",
            "OAuthToken": "{{resolve:secretsmanager:github-token:SecretString:token}}"
          },
          "outputArtifacts": [{"name": "SourceOutput"}]
        }]
      },
      {
        "name": "Build",
        "actions": [{
          "name": "BuildAction",
          "actionTypeId": {"category": "Build", "owner": "AWS", "provider": "CodeBuild", "version": "1"},
          "configuration": {"ProjectName": "LearnbayDevOps-Build"},
          "inputArtifacts": [{"name": "SourceOutput"}],
          "outputArtifacts": [{"name": "BuildOutput"}]
        }]
      },
      {
        "name": "MergeToMain",
        "actions": [{
          "name": "MergeAction",
          "actionTypeId": {"category": "Invoke", "owner": "AWS", "provider": "Lambda", "version": "1"},
          "configuration": {"FunctionName": "github-merge-function"},
          "inputArtifacts": [{"name": "BuildOutput"}]
        }]
      }
    ]
  }
}
EOF

aws codepipeline create-pipeline --cli-input-json file://pipeline.json
```

## Demo Time! 🚀

### Create develop branch and test:
```bash
cd /Users/abhi/codeclub/LearnbayDevOps4Aug
git checkout -b develop
git push origin develop

# Make a change
echo "// Demo change $(date)" >> app/app.js
git add .
git commit -m "Demo: Pipeline trigger test"
git push origin develop
```

### Monitor pipeline:
```bash
aws codepipeline get-pipeline-state --name LearnbayDevOps-Pipeline
```

**Expected Result**: Pipeline triggers → Build succeeds → Auto-merge to main branch!