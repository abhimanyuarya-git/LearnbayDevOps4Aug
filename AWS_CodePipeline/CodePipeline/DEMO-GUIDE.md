# AWS CodePipeline Live Demo Guide

## Step-by-Step Implementation Process

### Phase 1: Prerequisites Setup (5 minutes)

#### 1.1 AWS Account Setup
```bash
# Configure AWS CLI
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output format (json)

# Verify configuration
aws sts get-caller-identity
```

#### 1.2 GitHub Personal Access Token
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate token with scopes: `repo`, `admin:repo_hook`
3. Copy token for later use

### Phase 2: AWS Services Setup (15 minutes)

#### 2.1 Store GitHub Token in AWS Secrets Manager
```bash
aws secretsmanager create-secret \
    --name "github-token" \
    --description "GitHub token for CodePipeline" \
    --secret-string '{"token":"ghp_your_token_here"}'
```

#### 2.2 Create S3 Bucket for Artifacts
```bash
# Create unique bucket name
BUCKET_NAME="codepipeline-artifacts-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled
```

#### 2.3 Create IAM Roles
```bash
# CodePipeline Service Role
aws iam create-role \
    --role-name CodePipelineServiceRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "codepipeline.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

aws iam attach-role-policy \
    --role-name CodePipelineServiceRole \
    --policy-arn arn:aws:iam::aws:policy/AWSCodePipelineFullAccess

# CodeBuild Service Role
aws iam create-role \
    --role-name CodeBuildServiceRole \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "codebuild.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

aws iam attach-role-policy \
    --role-name CodeBuildServiceRole \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
```

### Phase 3: CodeBuild Project Creation (5 minutes)

#### 3.1 Create CodeBuild Project
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws codebuild create-project \
    --name "LearnbayDevOps-Build" \
    --source '{
        "type": "GITHUB",
        "location": "https://github.com/YOUR_USERNAME/LearnbayDevOps4Aug.git",
        "buildspec": "buildspec.yml"
    }' \
    --artifacts '{
        "type": "S3",
        "location": "'$BUCKET_NAME'/builds"
    }' \
    --environment '{
        "type": "LINUX_CONTAINER",
        "image": "aws/codebuild/amazonlinux2-x86_64-standard:4.0",
        "computeType": "BUILD_GENERAL1_MEDIUM"
    }' \
    --service-role "arn:aws:iam::$ACCOUNT_ID:role/CodeBuildServiceRole"
```

### Phase 4: CodePipeline Creation (10 minutes)

#### 4.1 Create Pipeline with Auto-Merge
```bash
aws codepipeline create-pipeline \
    --pipeline '{
        "name": "LearnbayDevOps-Pipeline",
        "roleArn": "arn:aws:iam::'$ACCOUNT_ID':role/CodePipelineServiceRole",
        "artifactStore": {
            "type": "S3",
            "location": "'$BUCKET_NAME'"
        },
        "stages": [
            {
                "name": "Source",
                "actions": [{
                    "name": "SourceAction",
                    "actionTypeId": {
                        "category": "Source",
                        "owner": "ThirdParty",
                        "provider": "GitHub",
                        "version": "1"
                    },
                    "configuration": {
                        "Owner": "YOUR_USERNAME",
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
                    "actionTypeId": {
                        "category": "Build",
                        "owner": "AWS",
                        "provider": "CodeBuild",
                        "version": "1"
                    },
                    "configuration": {
                        "ProjectName": "LearnbayDevOps-Build"
                    },
                    "inputArtifacts": [{"name": "SourceOutput"}],
                    "outputArtifacts": [{"name": "BuildOutput"}]
                }]
            },
            {
                "name": "MergeToMain",
                "actions": [{
                    "name": "MergeAction",
                    "actionTypeId": {
                        "category": "Invoke",
                        "owner": "AWS",
                        "provider": "Lambda",
                        "version": "1"
                    },
                    "configuration": {
                        "FunctionName": "github-merge-function"
                    },
                    "inputArtifacts": [{"name": "BuildOutput"}]
                }]
            }
        ]
    }'
```

## Live Demo Steps

### Demo Preparation (2 minutes)

1. **Create develop branch**:
```bash
cd /Users/abhi/codeclub/LearnbayDevOps4Aug
git checkout -b develop
git push origin develop
```

2. **Update pipeline configuration** with your GitHub username

### Demo Execution (5 minutes)

#### Step 1: Make a Code Change
```bash
# Edit app.js to add a new feature
echo 'console.log("New feature added!");' >> app/app.js

git add .
git commit -m "Add new feature - demo change"
git push origin develop
```

#### Step 2: Monitor Pipeline
```bash
# Watch pipeline execution
aws codepipeline get-pipeline-state --name LearnbayDevOps-Pipeline

# Check build logs
aws logs tail /aws/codebuild/LearnbayDevOps-Build --follow
```

#### Step 3: Verify Auto-Merge
```bash
# Check if changes merged to main
git checkout main
git pull origin main
git log --oneline -5
```

## Expected Demo Flow

1. **Push to develop** → Pipeline triggers automatically
2. **Source stage** → Pulls code from develop branch
3. **Build stage** → Runs tests, linting, builds application
4. **Merge stage** → Auto-merges to main branch on success
5. **Notification** → Success/failure notifications

## Troubleshooting Commands

```bash
# Check pipeline status
aws codepipeline list-pipeline-executions --pipeline-name LearnbayDevOps-Pipeline

# View build details
aws codebuild batch-get-builds --ids $(aws codebuild list-builds-for-project --project-name LearnbayDevOps-Build --query 'ids[0]' --output text)

# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix /aws/codebuild/
```

## Demo Success Criteria

✅ Pipeline triggers on push to develop branch
✅ Build stage completes successfully  
✅ Tests pass and code quality checks pass
✅ Code automatically merges to main branch
✅ Notifications sent on success/failure