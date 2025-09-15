# Step 2: AWS CodeArtifact Setup

## 2.1 Create CodeArtifact Domain

```bash
# Create domain
aws codeartifact create-domain \
    --domain my-company-domain \
    --region us-east-1
```

## 2.2 Create Repository

```bash
# Create repository
aws codeartifact create-repository \
    --domain my-company-domain \
    --repository my-npm-repo \
    --description "NPM packages repository" \
    --upstreams repositoryName=npm-store
```

## 2.3 Configure npm to use CodeArtifact

```bash
# Get authorization token
aws codeartifact get-authorization-token \
    --domain my-company-domain \
    --query authorizationToken \
    --output text

# Configure npm
aws codeartifact login \
    --tool npm \
    --repository my-npm-repo \
    --domain my-company-domain
```

## 2.4 Create .npmrc Configuration

Create `.npmrc` file in your project:

```
registry=https://my-company-domain-123456789012.d.codeartifact.us-east-1.amazonaws.com/npm/my-npm-repo/
//my-company-domain-123456789012.d.codeartifact.us-east-1.amazonaws.com/npm/my-npm-repo/:_authToken=${CODEARTIFACT_AUTH_TOKEN}
```

## Next Step
Proceed to Step 3: AWS CodeBuild Configuration