# VPC Module

## Overview
This module creates a VPC with public and private subnets, NAT gateways, and internet gateway.

## Features
- VPC with DNS support
- Public and private subnets across multiple AZs
- Internet Gateway for public subnets
- NAT Gateways for private subnet internet access
- Configurable subnet CIDR blocks
- Route tables and associations

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = "my-app"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  enable_nat_gateway   = true

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| public_subnet_cidrs | CIDR blocks for public subnets | `list(string)` | n/a | yes |
| private_subnet_cidrs | CIDR blocks for private subnets | `list(string)` | n/a | yes |
| availability_zones | Availability zones for subnets | `list(string)` | n/a | yes |
| enable_nat_gateway | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| public_subnet_ids | IDs of the public subnets |
| private_subnet_ids | IDs of the private subnets |
| internet_gateway_id | ID of the Internet Gateway |
| nat_gateway_ids | IDs of the NAT Gateways |
| public_route_table_id | ID of the public route table |
| private_route_table_ids | IDs of the private route tables |

