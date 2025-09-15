# Step 3: AWS CodeBuild Setup

## 3.1 Create CodeBuild Service Role

```bash
# Create trust policy for CodeBuild
cat > codebuild-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
    --role-name CodeBuildServiceRole \
    --assume-role-policy-document file://codebuild-trust-policy.json

# Attach policies
aws iam attach-role-policy \
    --role-name CodeBuildServiceRole \
    --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

aws iam attach-role-policy \
    --role-name CodeBuildServiceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

## 3.2 Create CodeBuild Project

```bash
# Create CodeBuild project configuration
cat > codebuild-project.json << EOF
{
  "name": "my-app-build",
  "description": "Build project for my application",
  "source": {
    "type": "GITHUB",
    "location": "https://github.com/your-username/LearnbayDevOps4Aug.git",
    "buildspec": "buildspec.yml"
  },
  "artifacts": {
    "type": "S3",
    "location": "my-codebuild-artifacts/builds"
  },
  "environment": {
    "type": "LINUX_CONTAINER",
    "image": "aws/codebuild/amazonlinux2-x86_64-standard:4.0",
    "computeType": "BUILD_GENERAL1_MEDIUM",
    "environmentVariables": [
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "us-east-1"
      }
    ]
  },
  "serviceRole": "arn:aws:iam::ACCOUNT_ID:role/CodeBuildServiceRole"
}
EOF

# Create the project
aws codebuild create-project --cli-input-json file://codebuild-project.json
```

## 3.3 Test Build

```bash
# Start a build
aws codebuild start-build --project-name my-app-build
```

## Next Step
Proceed to Step 4: AWS CodeDeploy Setup