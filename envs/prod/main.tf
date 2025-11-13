terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
      Project     = "Medical-App"
      Layer       = "ECR"
    }
  }
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = "prod"

  services = var.services
}

