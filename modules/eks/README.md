# EKS Module

## Overview
This module creates an Amazon EKS cluster with managed node groups and IRSA support.

## Features
- EKS cluster with configurable Kubernetes version
- Managed node groups with auto-scaling
- IRSA (IAM Roles for Service Accounts) support
- CloudWatch logging
- Encryption at rest for secrets
- Private/public endpoint configuration

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name = "my-cluster"
  subnet_ids   = module.vpc.private_subnet_ids

  node_groups = {
    main = {
      instance_types  = ["t3.medium"]
      capacity_type   = "ON_DEMAND"
      disk_size       = 50
      ami_type        = "AL2_x86_64"
      desired_size    = 2
      max_size        = 4
      min_size        = 1
      max_unavailable = 1
      labels          = {}
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

