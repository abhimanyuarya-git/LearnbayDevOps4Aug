# Step 6: AWS CodeGuru Integration

## 6.1 CodeGuru Reviewer Setup

### Enable CodeGuru Reviewer for Repository

```bash
# Associate GitHub repository with CodeGuru Reviewer
aws codeguru-reviewer associate-repository \
    --repository '{"GitHubEnterpriseServer":{"Name":"LearnbayDevOps4Aug","Owner":"your-github-username","ConnectionArn":"arn:aws:codestar-connections:us-east-1:ACCOUNT_ID:connection/connection-id"}}' \
    --type GitHubEnterpriseServer
```

### Create CodeGuru Reviewer Configuration

```yaml
# .codeguru-reviewer.yml
version: 1.0
rules:
  - name: security-best-practices
    enabled: true
  - name: code-quality
    enabled: true
  - name: performance
    enabled: true
  - name: maintainability
    enabled: true

exclude_patterns:
  - "node_modules/**"
  - "*.test.js"
  - "coverage/**"
```

## 6.2 CodeGuru Profiler Setup

### Create Profiling Group

```bash
# Create profiling group
aws codeguruprofiler create-profiling-group \
    --profiling-group-name MyApp-Profiler \
    --compute-platform Default
```

### Add Profiler to Application

```javascript
// Add to your Node.js application
const { CodeGuruProfilerAgent } = require('@aws/codeguru-profiler-nodejs-agent');

// Initialize profiler
const profilingGroupName = 'MyApp-Profiler';
const region = 'us-east-1';

CodeGuruProfilerAgent.start({
    profilingGroupName,
    region
});
```

### Update package.json

```json
{
  "dependencies": {
    "@aws/codeguru-profiler-nodejs-agent": "^1.0.0"
  }
}
```

## 6.3 Integration with CodePipeline

### Add CodeGuru Review Stage

```json
{
  "name": "CodeReview",
  "actions": [
    {
      "name": "CodeGuruReview",
      "actionTypeId": {
        "category": "Invoke",
        "owner": "AWS",
        "provider": "Lambda",
        "version": "1"
      },
      "configuration": {
        "FunctionName": "trigger-codeguru-review"
      },
      "inputArtifacts": [
        {
          "name": "SourceOutput"
        }
      ]
    }
  ]
}
```

## Next Step
Proceed to Step 7: AWS CodeStar Project Management