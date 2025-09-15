# Step 7: AWS CodeStar Project Management

## 7.1 Create CodeStar Project

```bash
# Create CodeStar project
aws codestar create-project \
    --name MyApp-Project \
    --id myapp-project \
    --description "Complete CI/CD project with all AWS DevOps services" \
    --source-code '{
        "source": {
            "s3": {
                "bucketName": "my-codestar-templates",
                "bucketKey": "nodejs-template.zip"
            }
        }
    }' \
    --toolchain '{
        "source": {
            "s3": {
                "bucketName": "my-codestar-templates", 
                "bucketKey": "toolchain-template.yml"
            }
        },
        "roleArn": "arn:aws:iam::ACCOUNT_ID:role/CodeStarServiceRole"
    }'
```

## 7.2 CodeStar Toolchain Template

Create `toolchain-template.yml`:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::CodeStar-2018-08-01

Parameters:
  ProjectId:
    Type: String
    Description: CodeStar project ID
  
Resources:
  # GitHub Connection
  GitHubConnection:
    Type: AWS::CodeStarConnections::Connection
    Properties:
      ConnectionName: !Sub '${ProjectId}-github-connection'
      ProviderType: GitHub

  # CodeBuild Project
  CodeBuildProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: !Sub '${ProjectId}-build'
      ServiceRole: !GetAtt CodeBuildRole.Arn
      Source:
        Type: GITHUB
        Location: https://github.com/your-username/LearnbayDevOps4Aug.git
      Environment:
        Type: LINUX_CONTAINER
        Image: aws/codebuild/amazonlinux2-x86_64-standard:4.0
        ComputeType: BUILD_GENERAL1_MEDIUM

  # CodePipeline
  Pipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      Name: !Sub '${ProjectId}-pipeline'
      RoleArn: !GetAtt CodePipelineRole.Arn
      ArtifactStore:
        Type: S3
        Location: !Ref ArtifactBucket
      Stages:
        - Name: Source
          Actions:
            - Name: SourceAction
              ActionTypeId:
                Category: Source
                Owner: ThirdParty
                Provider: GitHub
                Version: '1'
              Configuration:
                Owner: your-github-username
                Repo: LearnbayDevOps4Aug
                Branch: main
                OAuthToken: '{{resolve:secretsmanager:github-token:SecretString:token}}'
              OutputArtifacts:
                - Name: SourceOutput
        - Name: Build
          Actions:
            - Name: BuildAction
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref CodeBuildProject
              InputArtifacts:
                - Name: SourceOutput
              OutputArtifacts:
                - Name: BuildOutput
```

## 7.3 Team Management

```bash
# Add team member
aws codestar associate-team-member \
    --project-id myapp-project \
    --user-arn arn:aws:iam::ACCOUNT_ID:user/developer1 \
    --project-role Developer

# List team members
aws codestar list-team-members --project-id myapp-project
```

## 7.4 Project Dashboard

The CodeStar dashboard provides:
- Project overview and metrics
- Pipeline status and history
- Team member management
- Resource monitoring
- Issue tracking integration

## Final Step: Complete Integration Testing