# Contributing Guide

Thank you for contributing to the Terraform App Services repository!

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- Access to both dev and prod AWS accounts
- Git

### Initial Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd terraform-app-svc
```

2. Configure AWS credentials for dev and prod accounts

3. Initialize Terraform for your environment:
```bash
make init-dev   # For dev
make init-prod  # For prod
```

## 📝 Development Workflow

### Making Changes

1. **Create a feature branch**:
```bash
git checkout -b feature/add-new-service
```

2. **Make your changes** in the appropriate files:
   - Module changes: `modules/ecr/`
   - Environment-specific: `envs/dev/` or `envs/prod/`

3. **Format your code**:
```bash
make fmt
```

4. **Validate your changes**:
```bash
make validate-dev
make validate-prod
```

5. **Plan your changes**:
```bash
make plan-dev   # Test in dev first
```

6. **Commit your changes**:
```bash
git add .
git commit -m "feat: add new service to ECR"
```

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Test updates

Examples:
```
feat: add notification-service to ECR repositories
fix: correct lifecycle policy for untagged images
docs: update README with new service information
chore: upgrade terraform provider to v5.30
```

### Pull Request Process

1. **Create a Pull Request** with:
   - Clear description of changes
   - Link to related issues
   - Screenshots/outputs if applicable

2. **PR Checks**:
   - Terraform format check
   - Terraform validation
   - Terraform plan for both environments
   - Code review approval

3. **Plan Review**:
   - Review the Terraform plan output posted in the PR
   - Ensure changes match expectations
   - Verify no unexpected resource destruction

4. **Merge**:
   - Once approved, merge to `main`
   - Dev environment will auto-deploy
   - Prod requires manual deployment

## 🔒 Security Guidelines

### Secrets Management

- **NEVER** commit:
  - AWS credentials
  - Account IDs (use GitHub Secrets)
  - Sensitive configuration values
  - `.tfstate` files

### Code Review Checklist

- [ ] No hardcoded credentials or secrets
- [ ] Proper tags applied to resources
- [ ] Lifecycle policies configured appropriately
- [ ] Changes tested in dev environment first
- [ ] Documentation updated
- [ ] Terraform formatted and validated

## 🧪 Testing

### Local Testing

1. **Test in Dev First**:
```bash
cd envs/dev
terraform plan -var-file=dev.tfvars
```

2. **Review Plan Output**:
   - Verify resource changes
   - Check for unexpected deletions
   - Validate naming conventions

3. **Apply to Dev**:
```bash
make apply-dev
```

4. **Verify Resources**:
```bash
make output-dev
aws ecr describe-repositories --region us-east-1
```

### Integration Testing

After applying changes:

1. Test ECR repository access
2. Verify image scanning works
3. Check lifecycle policies
4. Test image push/pull operations

## 📚 Adding New Services

To add a new microservice:

1. Edit `envs/dev/dev.tfvars`:
```hcl
services = [
  "api-gateway",
  "auth-service",
  "patient-service",
  "billing-service",
  "analytics-service",
  "your-new-service"  # Add here
]
```

2. Make the same change in `envs/prod/prod.tfvars`

3. Create a PR with the changes

4. After merge and deployment, the ECR repository will be created:
   - Dev: `<account-id>.dkr.ecr.us-east-1.amazonaws.com/dev/your-new-service`
   - Prod: `<account-id>.dkr.ecr.us-east-1.amazonaws.com/prod/your-new-service`

## 🐛 Troubleshooting

### Common Issues

**State Lock Error:**
```bash
# Unlock state (use with caution)
cd envs/dev
terraform force-unlock <LOCK_ID>
```

**Backend Initialization:**
```bash
# Reinitialize backend
cd envs/dev
terraform init -reconfigure
```

**Provider Errors:**
```bash
# Upgrade providers
cd envs/dev
terraform init -upgrade
```

## 📞 Getting Help

- Open an issue for bugs or feature requests
- Contact the DevOps team for AWS access issues
- Review existing PRs for examples

## 🎯 Best Practices

1. **Always test in dev first** before applying to prod
2. **Use descriptive commit messages** following conventions
3. **Keep changes small and focused** - one feature per PR
4. **Document your changes** in PR description
5. **Review Terraform plans carefully** before approving
6. **Tag all resources appropriately**
7. **Follow the principle of least privilege** for IAM
8. **Use immutable tags** to prevent overwrites
9. **Enable encryption** for all resources
10. **Implement lifecycle policies** to manage costs

## 📖 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS ECR User Guide](https://docs.aws.amazon.com/ecr/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## 📄 License

This project follows the company's internal licensing policies.

