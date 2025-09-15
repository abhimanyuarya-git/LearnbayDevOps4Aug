# Lambda Function Creation and Triggering Explained

## When Lambda Function is Created

### Step 1: Lambda Creation (During Setup Phase)
The Lambda function is created **before** the pipeline runs, during the initial setup:

```bash
# This happens during setup (Step 4 in QUICK-DEMO-SETUP.md)
./setup-lambda-merge.sh
```

**What happens inside setup-lambda-merge.sh:**
1. Creates IAM role for Lambda
2. Packages Python code into zip file
3. Creates Lambda function in AWS
4. Sets environment variables (GitHub owner, repo)

### Step 2: Lambda Function Details
```bash
# Function created with these specifications:
Function Name: github-merge-function
Runtime: Python 3.9
Handler: lambda-merge-function.lambda_handler
Timeout: 30 seconds
Environment Variables:
  - GITHUB_OWNER: your-github-username
  - GITHUB_REPO: LearnbayDevOps4Aug
```

## How Lambda Function is Triggered

### Trigger Mechanism: CodePipeline Action

The Lambda function is triggered as a **pipeline stage action**, not by events:

```json
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
    }
  }]
}
```

### Execution Flow:

1. **Source Stage** completes → Code pulled from GitHub develop branch
2. **Build Stage** completes → Tests pass, build succeeds  
3. **MergeToMain Stage** starts → **Lambda function is invoked**
4. Lambda function executes → Creates PR and merges develop to main

### Lambda Execution Process:

```python
# What happens when Lambda runs:
1. Get GitHub token from AWS Secrets Manager
2. Create Pull Request (develop → main)
3. Auto-merge the Pull Request
4. Return success/failure status to CodePipeline
```

## Visual Timeline

```
Time: 0s    → Pipeline starts (GitHub push to develop)
Time: 30s   → Source stage completes
Time: 2min  → Build stage completes (tests pass)
Time: 2m30s → Lambda function TRIGGERED by CodePipeline
Time: 2m35s → Lambda creates PR and merges to main
Time: 2m40s → Pipeline completes successfully
```

## Key Points:

- **Lambda is created ONCE** during setup (not per pipeline run)
- **Lambda is triggered BY CodePipeline** (not by GitHub webhooks)
- **Lambda only runs AFTER** build stage succeeds
- **Lambda execution is synchronous** - pipeline waits for response

## Alternative Trigger Methods (Not Used Here):

❌ **GitHub Webhooks** → Would trigger on every push
❌ **CloudWatch Events** → Would trigger on schedule  
❌ **API Gateway** → Would trigger on HTTP requests

✅ **CodePipeline Action** → Triggers only after successful build