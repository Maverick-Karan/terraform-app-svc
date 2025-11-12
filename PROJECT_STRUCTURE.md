# Project Structure

This document provides a comprehensive overview of the repository structure.

```
terraform-app-svc/
│
├── 📄 README.md                          # Main documentation
├── 📄 QUICKSTART.md                      # Quick start guide
├── 📄 CONTRIBUTING.md                    # Contribution guidelines
├── 📄 Makefile                           # Common commands for dev workflow
├── 📄 .gitignore                         # Git ignore rules
├── 📄 .pre-commit-config.yaml            # Pre-commit hooks configuration
├── 📄 .terraform-docs.yml                # Terraform docs configuration
│
├── 📁 modules/                           # Reusable Terraform modules
│   └── 📁 ecr/                           # ECR repository module
│       ├── main.tf                       # ECR resources and lifecycle policies
│       ├── variables.tf                  # Module input variables
│       ├── outputs.tf                    # Module outputs
│       └── README.md                     # Module documentation
│
├── 📁 envs/                              # Environment-specific configurations
│   ├── 📁 dev/                           # Development environment
│   │   ├── main.tf                       # Dev configuration and provider setup
│   │   ├── backend.tf                    # S3 backend configuration
│   │   ├── variables.tf                  # Dev input variables
│   │   ├── dev.tfvars                    # Dev variable values
│   │   └── outputs.tf                    # Dev outputs
│   │
│   └── 📁 prod/                          # Production environment
│       ├── main.tf                       # Prod configuration and provider setup
│       ├── backend.tf                    # S3 backend configuration
│       ├── variables.tf                  # Prod input variables
│       ├── prod.tfvars                   # Prod variable values
│       └── outputs.tf                    # Prod outputs
│
├── 📁 .github/                           # GitHub-specific files
│   └── 📁 workflows/                     # GitHub Actions workflows
│       └── terraform.yml                 # CI/CD pipeline for Terraform
│
├── 📁 scripts/                           # Utility scripts
│   ├── setup-aws-backend.sh              # Setup S3 backend and DynamoDB
│   └── setup-github-oidc.sh              # Setup GitHub OIDC provider and IAM role
│
└── 📁 iam-policies/                      # IAM policy templates
    ├── github-oidc-trust-policy.json     # OIDC trust policy template
    └── terraform-permissions-policy.json # Terraform permissions template
```

## 📋 File Descriptions

### Root Level Files

| File | Purpose |
|------|---------|
| `README.md` | Main documentation with architecture overview and usage |
| `QUICKSTART.md` | Step-by-step guide to get started quickly |
| `CONTRIBUTING.md` | Guidelines for contributing to the repository |
| `PROJECT_STRUCTURE.md` | This file - overview of repository structure |
| `Makefile` | Convenience commands for common operations |
| `.gitignore` | Specifies intentionally untracked files to ignore |
| `.pre-commit-config.yaml` | Pre-commit hooks for code quality |
| `.terraform-docs.yml` | Configuration for auto-generating documentation |

### Modules Directory

**`modules/ecr/`** - Reusable ECR module

- `main.tf`: Defines ECR repositories with security features and lifecycle policies
- `variables.tf`: Input variables for customization (environment, services, etc.)
- `outputs.tf`: Outputs repository URLs, ARNs, and names
- `README.md`: Module-specific documentation

**Key Features:**
- Creates ECR repositories with environment prefixes
- Enables image scanning on push
- Implements lifecycle policies for image retention
- Configures encryption and immutable tags

### Environments Directory

**`envs/dev/` and `envs/prod/`** - Environment-specific configurations

Each environment contains:
- `main.tf`: Terraform configuration and AWS provider setup
- `backend.tf`: S3 backend for state management
- `variables.tf`: Variable declarations
- `{env}.tfvars`: Actual variable values
- `outputs.tf`: Environment outputs

**Key Differences:**
- Separate AWS accounts (different account IDs)
- Isolated state management (separate S3 buckets)
- Different deployment workflows (auto vs manual)

### GitHub Actions

**`.github/workflows/terraform.yml`** - CI/CD Pipeline

**Triggers:**
- Push to main (on changes to `envs/**` or `modules/**`)
- Pull requests
- Manual workflow dispatch

**Workflow:**
1. Format check
2. Initialize Terraform
3. Validate configuration
4. Run plan
5. Comment plan on PR (if PR)
6. Apply to dev (auto on push to main)
7. Apply to prod (manual approval required)

### Scripts Directory

**`scripts/setup-aws-backend.sh`**
- Creates S3 bucket for Terraform state
- Creates DynamoDB table for state locking
- Configures encryption and versioning
- Blocks public access

Usage: `./scripts/setup-aws-backend.sh <env> <region>`

**`scripts/setup-github-oidc.sh`**
- Creates GitHub OIDC provider in AWS
- Creates IAM role with trust relationship
- Attaches permissions policy
- No long-lived credentials needed

Usage: `./scripts/setup-github-oidc.sh <env> <org> <repo>`

### IAM Policies Directory

**`iam-policies/github-oidc-trust-policy.json`**
- Template for OIDC trust relationship
- Allows GitHub Actions to assume IAM role
- Repository-specific constraints

**`iam-policies/terraform-permissions-policy.json`**
- Permissions for Terraform operations
- ECR full access
- S3 state management
- DynamoDB state locking
- KMS encryption

## 🔄 Data Flow

### Local Development
```
Developer → Local Terraform → AWS Dev/Prod Account
```

### CI/CD Pipeline
```
GitHub Push → GitHub Actions → OIDC Auth → AWS IAM Role → Terraform → AWS Resources
```

### State Management
```
Terraform → S3 Backend (State File)
          → DynamoDB (State Lock)
```

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│                   GitHub Actions                     │
│              (CI/CD Orchestration)                   │
└───────────────────┬─────────────────────────────────┘
                    │
                    ↓
┌─────────────────────────────────────────────────────┐
│              GitHub OIDC Provider                    │
│           (Secure Authentication)                    │
└───────────────────┬─────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        ↓                       ↓
┌───────────────┐       ┌───────────────┐
│  Dev Account  │       │ Prod Account  │
│               │       │               │
│  IAM Role     │       │  IAM Role     │
│  S3 Bucket    │       │  S3 Bucket    │
│  DynamoDB     │       │  DynamoDB     │
│  ECR Repos    │       │  ECR Repos    │
└───────────────┘       └───────────────┘
```

## 📊 Resource Naming Convention

### ECR Repositories
Format: `{environment}/{service-name}`

Examples:
- `dev/api-gateway`
- `prod/auth-service`

### AWS Resources
- S3 Bucket: `company-tfstate-{env}`
- DynamoDB Table: `company-tf-locks-{env}`
- IAM Role: `github-actions-tf-{env}`

### Tags
All resources include:
- `Environment`: dev or prod
- `ManagedBy`: Terraform
- `Project`: Medical-App
- `Layer`: ECR

## 🔐 Security Model

### Authentication
- **Local**: AWS CLI credentials
- **CI/CD**: GitHub OIDC (no long-lived credentials)

### Authorization
- Separate IAM roles per environment
- Least privilege permissions
- Environment-specific trust policies

### State Security
- Encrypted S3 buckets (AES256)
- Versioning enabled
- Public access blocked
- State locking via DynamoDB

### Container Security
- Image scanning on push
- Immutable image tags
- Encryption at rest
- Lifecycle policies

## 📝 Common Workflows

### Adding a New Service
1. Edit `envs/dev/dev.tfvars`
2. Edit `envs/prod/prod.tfvars`
3. Commit and push
4. Create PR
5. Review plan
6. Merge (dev auto-deploys)
7. Manually deploy to prod

### Updating Module
1. Edit `modules/ecr/*.tf`
2. Test in dev
3. Create PR
4. Review changes
5. Merge and deploy

### Emergency Rollback
1. Identify previous working state
2. Use `terraform state` commands
3. Or revert git commit
4. Redeploy

## 🔗 Dependencies

### External Dependencies
- AWS Account (2x - dev and prod)
- GitHub repository
- GitHub Actions
- S3 (for state)
- DynamoDB (for locking)

### Tool Dependencies
- Terraform >= 1.5.0
- AWS CLI
- Git
- Make (optional)
- terraform-docs (optional)
- pre-commit (optional)

## 📚 Additional Documentation

- [README.md](README.md) - Main documentation
- [QUICKSTART.md](QUICKSTART.md) - Getting started guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [modules/ecr/README.md](modules/ecr/README.md) - ECR module docs

## 🆘 Troubleshooting Reference

| Issue | Location | Solution |
|-------|----------|----------|
| State lock | `envs/{env}/` | `terraform force-unlock` |
| Backend error | `envs/{env}/backend.tf` | Verify S3 bucket exists |
| OIDC auth failed | IAM role trust policy | Check GitHub repo in trust policy |
| Module not found | `modules/ecr/` | Check relative path in `main.tf` |
| Variable error | `*.tfvars` | Verify variable names match `variables.tf` |

---

**Last Updated**: November 2025  
**Maintainer**: DevOps Team

