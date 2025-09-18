# AWS CLI Commands for learnbay-app Setup

## Create CodeDeploy Application
```bash
# Create application
aws deploy create-application \
    --application-name learnbay-app \
    --compute-platform Server

# Get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create deployment group
aws deploy create-deployment-group \
    --application-name learnbay-app \
    --deployment-group-name learnbay-app-DeploymentGroup \
    --service-role-arn arn:aws:iam::${ACCOUNT_ID}:role/CodeDeployServiceRole \
    --ec2-tag-filters Key=Name,Value=MyAppServer,Type=KEY_AND_VALUE
```

## Create CodeBuild Project
```bash
aws codebuild create-project \
    --name learnbay-app-Build \
    --source type=GITHUB,location=https://github.com/your-username/your-repo.git \
    --artifacts type=S3,location=your-codedeploy-bucket-name \
    --environment type=LINUX_CONTAINER,image=aws/codebuild/amazonlinux2-x86_64-standard:3.0,computeType=BUILD_GENERAL1_SMALL \
    --service-role arn:aws:iam::${ACCOUNT_ID}:role/CodeBuildServiceRole
```

## Create CodePipeline
```bash
aws codepipeline create-pipeline --cli-input-json '{
  "pipeline": {
    "name": "learnbay-app-Pipeline",
    "roleArn": "arn:aws:iam::ACCOUNT_ID:role/CodePipelineServiceRole",
    "artifactStore": {
      "type": "S3",
      "location": "your-codedeploy-bucket-name"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "Source",
            "actionTypeId": {
              "category": "Source",
              "owner": "ThirdParty",
              "provider": "GitHub",
              "version": "1"
            },
            "configuration": {
              "Owner": "your-github-username",
              "Repo": "your-repo-name",
              "Branch": "main",
              "OAuthToken": "your-github-token"
            },
            "outputArtifacts": [{"name": "SourceOutput"}]
          }
        ]
      },
      {
        "name": "Build",
        "actions": [
          {
            "name": "Build",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "learnbay-app-Build"
            },
            "inputArtifacts": [{"name": "SourceOutput"}],
            "outputArtifacts": [{"name": "BuildOutput"}]
          }
        ]
      },
      {
        "name": "Deploy",
        "actions": [
          {
            "name": "Deploy",
            "actionTypeId": {
              "category": "Deploy",
              "owner": "AWS",
              "provider": "CodeDeploy",
              "version": "1"
            },
            "configuration": {
              "ApplicationName": "learnbay-app",
              "DeploymentGroupName": "learnbay-app-DeploymentGroup"
            },
            "inputArtifacts": [{"name": "BuildOutput"}]
          }
        ]
      }
    ]
  }
}'
```

## Monitor and Test
```bash
# Trigger pipeline manually
aws codepipeline start-pipeline-execution --name learnbay-app-Pipeline

# Check deployment status
aws deploy list-deployments --application-name learnbay-app

# Get specific deployment details
aws deploy get-deployment --deployment-id YOUR-DEPLOYMENT-ID
```