# Migration Guide: From Manual Setup to Terraform

## ⚠️ DEPRECATED: Manual Setup Files

The following files are **deprecated** and kept for reference only:

### Legacy Manual Setup Files:
- `1-github-setup.md` - ❌ Use Terraform instead
- `2-codeartifact-setup.md` - ❌ Not needed for basic pipeline
- `3-codebuild-setup.md` - ❌ Use Terraform instead
- `4-codedeploy-setup.md` - ❌ Use Terraform instead
- `5-codepipeline-setup.md` - ❌ Use Terraform instead
- `6-codeguru-setup.md` - ❌ Use Terraform instead
- `7-codestar-setup.md` - ❌ Use Terraform instead
- `8-complete-setup-guide.md` - ❌ Use Terraform instead
- `DEMO-GUIDE.md` - ❌ Use TERRAFORM-SETUP.md instead
- `QUICK-DEMO-SETUP.md` - ❌ Use ./deploy.sh instead
- `lambda-creation-commands.sh` - ❌ Use Terraform instead
- `setup-lambda-merge.sh` - ❌ Use Terraform instead

## ✅ CURRENT: Terraform + Python Solution

### Active Files:
- `terraform/` - **Infrastructure as Code**
- `python-automation/` - **GitHub integration**
- `deploy.sh` - **One-command deployment**
- `TERRAFORM-SETUP.md` - **Current setup guide**
- `SRE-COMPLIANCE.md` - **SRE best practices**

## Migration Steps

### If you used manual setup before:

1. **Cleanup existing resources**:
```bash
# Delete manually created resources
aws codepipeline delete-pipeline --name MyApp-Pipeline
aws codebuild delete-project --name my-app-build
aws lambda delete-function --function-name github-merge-function
# ... cleanup other resources
```

2. **Use new Terraform solution**:
```bash
./deploy.sh
```

### Benefits of Migration:
- ⚡ **5 minutes** vs 30+ minutes setup time
- 🔄 **Reproducible** infrastructure
- 🏷️ **Proper tagging** and resource management
- 🔒 **Security best practices** built-in
- 📊 **Monitoring and logging** included
- 💰 **Cost optimization** with easy cleanup

## File Status Reference

| File | Status | Replacement |
|------|--------|-------------|
| Manual setup guides | ❌ Deprecated | `terraform/` |
| Shell scripts | ❌ Deprecated | `deploy.sh` |
| Demo guides | ❌ Deprecated | `TERRAFORM-SETUP.md` |
| Lambda scripts | ❌ Deprecated | `terraform/main.tf` |
| README.md | ✅ Updated | Current solution |
| buildspec.yml | ✅ Updated | SRE compliant |
| appspec.yml | ✅ Current | No changes |
| scripts/ | ✅ Current | No changes |