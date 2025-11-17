# Data Layer - RDS, Redis, MSK, S3, ECR

# Note: ECR module doesn't require VPC, so it can be deployed independently
# Remote state reference is commented out until platform layer is deployed
# Uncomment when you need to reference platform layer outputs (e.g., for RDS, Redis)

# data "terraform_remote_state" "platform" {
#   backend = "s3"
#   config = {
#     bucket = "med-app-remotestate"
#     key    = "med-app/dev/platform.tfstate"
#     region = "us-east-1"
#   }
# }

# ECR Module
module "ecr" {
  source = "../../../modules/ecr"

  environment = "dev"
  services    = var.services
}

# RDS Module (optional - uncomment when ready)
# module "rds" {
#   source = "../../../modules/rds"
#
#   identifier     = "med-app-dev-db"
#   engine         = "postgres"
#   engine_version = "15.4"
#   instance_class = "db.t3.micro"
#   allocated_storage = 20
#   db_name        = "medapp"
#   username       = var.db_username
#   password       = var.db_password
#   subnet_ids     = data.terraform_remote_state.platform.outputs.private_subnet_ids
#   security_group_ids = [aws_security_group.rds.id]
# }

# Redis Module (optional - uncomment when ready)
# module "redis" {
#   source = "../../../modules/redis"
#
#   replication_group_id = "med-app-dev-redis"
#   node_type           = "cache.t3.micro"
#   subnet_ids          = data.terraform_remote_state.platform.outputs.private_subnet_ids
#   security_group_ids  = [aws_security_group.redis.id]
# }

