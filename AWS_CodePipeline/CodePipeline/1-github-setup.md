# Step 1: GitHub Repository Setup

## 1.1 GitHub Repository Configuration

Using existing GitHub repository at: `/Users/abhi/codeclub/LearnbayDevOps4Aug`

```bash
# Navigate to your existing repository
cd /Users/abhi/codeclub/LearnbayDevOps4Aug

# Verify repository status
git remote -v
git status
```

## 1.2 Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with these scopes:
   - `repo` (Full control of private repositories)
   - `admin:repo_hook` (Full control of repository hooks)

## 1.3 Store GitHub Token in AWS Secrets Manager

```bash
# Store GitHub token securely
aws secretsmanager create-secret \
    --name "github-token" \
    --description "GitHub personal access token for CodePipeline" \
    --secret-string '{"token":"your-github-personal-access-token"}'
```

## 1.4 Add Required Files to Repository

```bash
# Copy AWS configuration files to your GitHub repo
cp ../aws-codepipeline-setup/buildspec.yml .
cp ../aws-codepipeline-setup/appspec.yml .
cp -r ../aws-codepipeline-setup/scripts .

# Commit changes
git add .
git commit -m "Add AWS CodePipeline configuration files"
git push origin main
```

## Next Step
Proceed to Step 2: AWS CodeArtifact Setup