# Terraform App Services (ECR Layer)

## 📋 Overview

This repository manages AWS Elastic Container Registry (ECR) repositories for the medical application microservices across development and production environments.

## 🏗️ Architecture

This is a **layered Terraform setup** with:
- **Separate AWS accounts** for dev and prod (different account IDs)
- **Isolated state management** per environment (separate S3 backends)
- **OIDC authentication** for GitHub Actions (no long-lived credentials)
- **Reusable ECR module** for consistent configuration

## 📁 Repository Structure

```
terraform-app-svc/
├── modules/
│   └── ecr/                    # Reusable ECR module
│       ├── main.tf             # ECR resources and lifecycle policies
│       ├── variables.tf        # Module inputs
│       ├── outputs.tf          # Module outputs
│       └── README.md           # Module documentation
│
├── envs/
│   ├── dev/                    # Development environment
│   │   ├── main.tf             # Dev configuration
│   │   ├── backend.tf          # Dev S3 backend
│   │   ├── variables.tf        # Dev variables
│   │   ├── dev.tfvars          # Dev values
│   │   └── outputs.tf          # Dev outputs
│   │
│   └── prod/                   # Production environment
│       ├── main.tf             # Prod configuration
│       ├── backend.tf          # Prod S3 backend
│       ├── variables.tf        # Prod variables
│       ├── prod.tfvars         # Prod values
│       └── outputs.tf          # Prod outputs
│
├── .github/
│   └── workflows/
│       └── terraform.yml       # CI/CD pipeline
│
└── README.md                   # This file
```

## 🚀 Microservices

The following ECR repositories are created for each environment:

1. **api-gateway** - API Gateway service
2. **auth-service** - Authentication service
3. **patient-service** - Patient management service
4. **billing-service** - Billing and payments service
5. **analytics-service** - Analytics and reporting service

Each repository is named as: `{environment}/{service-name}`
- Example: `dev/api-gateway`, `prod/auth-service`

## 🔐 Prerequisites

### 1. AWS Account Setup

You need two AWS accounts:
- **Dev Account**: Development environment
- **Prod Account**: Production environment

### 2. S3 Backend Buckets

Create S3 buckets and DynamoDB tables for state management:

**Dev Account:**
```bash
aws s3api create-bucket --bucket company-tfstate-dev --region us-east-1
aws dynamodb create-table \
  --table-name company-tf-locks-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

**Prod Account:**
```bash
aws s3api create-bucket --bucket company-tfstate-prod --region us-east-1
aws dynamodb create-table \
  --table-name company-tf-locks-prod \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 3. GitHub OIDC IAM Roles

Create OIDC provider and IAM roles in each AWS account:

```bash
# In each account (dev and prod)
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM role: github-actions-tf-dev (or github-actions-tf-prod)
# with trust policy for your GitHub repo
```

### 4. GitHub Secrets

Add these secrets to your GitHub repository:
- `AWS_ACCOUNT_ID_DEV` - Dev AWS account ID
- `AWS_ACCOUNT_ID_PROD` - Prod AWS account ID

## 💻 Local Development

### Initialize and Plan

**For Dev:**
```bash
cd envs/dev
terraform init
terraform plan -var-file=dev.tfvars
```

**For Prod:**
```bash
cd envs/prod
terraform init
terraform plan -var-file=prod.tfvars
```

### Apply Changes

**Dev:**
```bash
cd envs/dev
terraform apply -var-file=dev.tfvars
```

**Prod:**
```bash
cd envs/prod
terraform apply -var-file=prod.tfvars
```

### View Outputs

```bash
terraform output
terraform output -json ecr_repo_urls
```

## 🔄 CI/CD Workflow

### Automatic Triggers

1. **Pull Requests**: 
   - Runs `terraform plan` for both environments
   - Posts plan output as PR comment

2. **Push to Main**:
   - **Dev**: Automatically runs `terraform apply` ✅
   - **Prod**: Only runs `terraform plan` (manual apply required) 🔒

### Manual Deployment (Prod)

To deploy to production:

1. Go to **Actions** tab in GitHub
2. Select **Terraform ECR Layer** workflow
3. Click **Run workflow**
4. Choose:
   - Environment: `prod`
   - Action: `apply`
5. Click **Run workflow**

## 🛡️ Security Features

- ✅ **Immutable image tags** - Prevents tag overwrites
- ✅ **Image scanning on push** - Automatic vulnerability scanning
- ✅ **AES256 encryption** - At-rest encryption for images
- ✅ **Lifecycle policies** - Automatic cleanup of old/untagged images
- ✅ **OIDC authentication** - No long-lived AWS credentials
- ✅ **State locking** - DynamoDB prevents concurrent modifications
- ✅ **Encrypted state** - S3 state files are encrypted

## 📊 Outputs

After applying, you'll get:

- **ecr_repo_urls**: Map of service names to ECR repository URLs
- **ecr_repo_arns**: Map of service names to ECR repository ARNs
- **ecr_repo_names**: Map of service names to repository names
- **ecr_registry_id**: The AWS ECR registry ID

Example output:
```json
{
  "ecr_repo_urls": {
    "api-gateway": "123456789012.dkr.ecr.us-east-1.amazonaws.com/dev/api-gateway",
    "auth-service": "123456789012.dkr.ecr.us-east-1.amazonaws.com/dev/auth-service",
    ...
  }
}
```

## 🔧 Customization

### Adding a New Service

Edit `envs/{env}/{env}.tfvars`:

```hcl
services = [
  "api-gateway",
  "auth-service",
  "patient-service",
  "billing-service",
  "analytics-service",
  "new-service"  # Add your new service
]
```

### Changing Region

Edit `envs/{env}/{env}.tfvars`:

```hcl
aws_region = "us-west-2"  # Change region
```

Also update `backend.tf` region accordingly.

## 📝 Notes

- Each environment has its own AWS account with separate account IDs
- State files are stored separately per environment
- Dev deploys automatically on merge to main
- Prod requires manual approval via workflow dispatch
- Lifecycle policies keep last 30 tagged images and remove untagged after 7 days

## 🆘 Troubleshooting

### State Lock Error
```bash
terraform force-unlock <LOCK_ID>
```

### Backend Initialization Error
Ensure S3 bucket and DynamoDB table exist in the correct AWS account.

### OIDC Authentication Error
Verify IAM role trust policy includes your GitHub repository.

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECR User Guide](https://docs.aws.amazon.com/ecr/)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## 📧 Support

For issues or questions, please open a GitHub issue or contact the DevOps team.

