# 🚀 Quick Start Guide

This guide will help you get up and running with the Terraform App Services repository in minutes.

## Prerequisites

- [x] AWS CLI installed and configured
- [x] Terraform >= 1.5.0 installed
- [x] Access to dev and/or prod AWS accounts
- [x] Git installed

## Step 1: Setup AWS Backend Infrastructure

Run the setup script for each environment:

```bash
# For Dev
./scripts/setup-aws-backend.sh dev us-east-1

# For Prod
./scripts/setup-aws-backend.sh prod us-east-1
```

This creates:
- S3 bucket for Terraform state
- DynamoDB table for state locking
- Proper encryption and versioning

## Step 2: Setup GitHub OIDC (For CI/CD)

If using GitHub Actions, setup OIDC provider and IAM roles:

```bash
# Replace with your GitHub org and repo name
./scripts/setup-github-oidc.sh dev YOUR_ORG YOUR_REPO
./scripts/setup-github-oidc.sh prod YOUR_ORG YOUR_REPO
```

This creates:
- GitHub OIDC provider in AWS
- IAM role with appropriate permissions
- Trust relationship with your GitHub repository

## Step 3: Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AWS_ACCOUNT_ID_DEV`: Your dev AWS account ID
- `AWS_ACCOUNT_ID_PROD`: Your prod AWS account ID

## Step 4: Initialize Terraform

```bash
# For Dev
make init-dev

# For Prod
make init-prod
```

## Step 5: Plan and Apply

### Development Environment

```bash
# See what will be created
make plan-dev

# Apply changes
make apply-dev

# View outputs
make output-dev
```

### Production Environment

```bash
# See what will be created
make plan-prod

# Apply changes (be careful!)
make apply-prod

# View outputs
make output-prod
```

## Quick Commands Reference

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make init-dev` | Initialize dev environment |
| `make plan-dev` | Plan dev changes |
| `make apply-dev` | Apply dev changes |
| `make destroy-dev` | Destroy dev resources |
| `make fmt` | Format all Terraform files |
| `make validate-dev` | Validate dev configuration |
| `make output-dev` | Show dev outputs |
| `make clean` | Clean Terraform cache |

Replace `-dev` with `-prod` for production commands.

## Using the ECR Repositories

After deployment, your ECR repositories will be available at:

```
<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<ENV>/<SERVICE>
```

Example:
```
123456789012.dkr.ecr.us-east-1.amazonaws.com/dev/api-gateway
```

### Login to ECR

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### Push an Image

```bash
# Tag your image
docker tag my-service:latest \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/dev/my-service:v1.0.0

# Push the image
docker push \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/dev/my-service:v1.0.0
```

## CI/CD Workflow

### Automatic Deployment

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/add-new-service
   ```

2. **Make your changes:**
   - Edit `envs/dev/dev.tfvars` or `envs/prod/prod.tfvars`
   - Or modify the ECR module in `modules/ecr/`

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "feat: add notification-service"
   git push origin feature/add-new-service
   ```

4. **Create Pull Request:**
   - GitHub Actions will run `terraform plan`
   - Review the plan output in PR comments
   - Get approval from team

5. **Merge to main:**
   - Dev environment deploys automatically ✅
   - Prod requires manual approval 🔒

### Manual Production Deployment

1. Go to **Actions** tab in GitHub
2. Select **Terraform ECR Layer** workflow
3. Click **Run workflow**
4. Select:
   - Environment: `prod`
   - Action: `apply`
5. Click **Run workflow**

## Troubleshooting

### State Lock Issue

```bash
# Get lock info
cd envs/dev
terraform force-unlock <LOCK_ID>
```

### Backend Error

```bash
# Reinitialize
cd envs/dev
terraform init -reconfigure
```

### Provider Version Conflicts

```bash
# Upgrade providers
cd envs/dev
terraform init -upgrade
```

### View Current State

```bash
cd envs/dev
terraform show
```

## Next Steps

- [ ] Review [README.md](README.md) for detailed documentation
- [ ] Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- [ ] Setup pre-commit hooks for automatic validation
- [ ] Customize services list in `*.tfvars` files
- [ ] Configure additional ECR settings if needed

## Support

- **Issues**: Open a GitHub issue
- **Questions**: Contact DevOps team
- **Documentation**: See [README.md](README.md)

## Security Notes

⚠️ **Important:**
- Never commit `.tfstate` files
- Never commit AWS credentials
- Always test in dev first
- Review plans carefully before applying
- Use OIDC instead of long-lived credentials
- Enable MFA for production accounts

## Useful Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS ECR Docs](https://docs.aws.amazon.com/ecr/)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

---

**Ready to go!** Start with `make plan-dev` to see what will be created. 🎉

