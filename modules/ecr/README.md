# ECR Module

## Overview
This module creates AWS Elastic Container Registry (ECR) repositories for application microservices.

## Features
- Creates ECR repositories with environment prefixes
- Enables image scanning on push for security
- Uses AES256 encryption by default
- Immutable image tags to prevent overwrites
- Lifecycle policies to manage image retention
- Automatic cleanup of untagged images

## Usage

```hcl
module "ecr" {
  source      = "../../modules/ecr"
  environment = "dev"
  
  services = [
    "api-gateway",
    "auth-service",
    "patient-service",
    "billing-service",
    "analytics-service"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, prod) | `string` | n/a | yes |
| services | List of microservices to create ECR repositories for | `list(string)` | See defaults | no |
| image_tag_mutability | Image tag mutability setting | `string` | `"IMMUTABLE"` | no |
| scan_on_push | Enable image scanning on push | `bool` | `true` | no |
| encryption_type | Encryption type for ECR | `string` | `"AES256"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecr_repo_urls | Map of service names to ECR repository URLs |
| ecr_repo_arns | Map of service names to ECR repository ARNs |
| ecr_repo_names | Map of service names to ECR repository names |
| ecr_registry_id | The registry ID where repositories are created |

## Lifecycle Policies

- **Tagged Images**: Keeps the last 30 images with version tags (v*)
- **Untagged Images**: Automatically removes images after 7 days

## Tags

All resources are automatically tagged with:
- `Environment`: The environment name
- `ManagedBy`: "Terraform"
- `Service`: The service name

