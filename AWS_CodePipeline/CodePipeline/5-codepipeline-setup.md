# Step 5: AWS CodePipeline Creation

## 5.1 Create CodePipeline Service Role

```bash
# Create trust policy for CodePipeline
cat > codepipeline-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
    --role-name CodePipelineServiceRole \
    --assume-role-policy-document file://codepipeline-trust-policy.json

# Attach policy
aws iam attach-role-policy \
    --role-name CodePipelineServiceRole \
    --policy-arn arn:aws:iam::aws:policy/AWSCodePipelineFullAccess
```

## 5.2 Create S3 Bucket for Artifacts

```bash
# Create S3 bucket for pipeline artifacts
aws s3 mb s3://my-codepipeline-artifacts-bucket-unique-name

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket my-codepipeline-artifacts-bucket-unique-name \
    --versioning-configuration Status=Enabled
```

## 5.3 Create CodePipeline

```bash
# Create pipeline configuration
cat > pipeline-config.json << EOF
{
  "pipeline": {
    "name": "MyApp-Pipeline",
    "roleArn": "arn:aws:iam::ACCOUNT_ID:role/CodePipelineServiceRole",
    "artifactStore": {
      "type": "S3",
      "location": "my-codepipeline-artifacts-bucket-unique-name"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "SourceAction",
            "actionTypeId": {
              "category": "Source",
              "owner": "ThirdParty",
              "provider": "GitHub",
              "version": "1"
            },
            "configuration": {
              "Owner": "your-github-username",
              "Repo": "LearnbayDevOps4Aug",
              "Branch": "main",
              "OAuthToken": "{{resolve:secretsmanager:github-token:SecretString:token}}"
            },
            "outputArtifacts": [
              {
                "name": "SourceOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Build",
        "actions": [
          {
            "name": "BuildAction",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "configuration": {
              "ProjectName": "my-app-build"
            },
            "inputArtifacts": [
              {
                "name": "SourceOutput"
              }
            ],
            "outputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      },
      {
        "name": "Deploy",
        "actions": [
          {
            "name": "DeployAction",
            "actionTypeId": {
              "category": "Deploy",
              "owner": "AWS",
              "provider": "CodeDeploy",
              "version": "1"
            },
            "configuration": {
              "ApplicationName": "MyApp",
              "DeploymentGroupName": "Production"
            },
            "inputArtifacts": [
              {
                "name": "BuildOutput"
              }
            ]
          }
        ]
      }
    ]
  }
}
EOF

# Create the pipeline
aws codepipeline create-pipeline --cli-input-json file://pipeline-config.json
```

## 5.4 Test Pipeline

```bash
# Start pipeline execution
aws codepipeline start-pipeline-execution --name MyApp-Pipeline

# Check pipeline status
aws codepipeline get-pipeline-state --name MyApp-Pipeline
```

## Next Step
Proceed to Step 6: AWS CodeGuru Integration