# Platform Layer - VPC, EKS, Networking

# VPC Module
module "vpc" {
  source = "../../../modules/vpc"

  name_prefix          = "med-app-dev"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = true

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# EKS Module (optional - uncomment when ready)
# module "eks" {
#   source = "../../../modules/eks"
#
#   cluster_name = "med-app-dev"
#   subnet_ids   = module.vpc.private_subnet_ids
#
#   node_groups = var.eks_node_groups
#
#   tags = {
#     Environment = "dev"
#     ManagedBy   = "Terraform"
#   }
# }

