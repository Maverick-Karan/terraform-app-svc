# App Layer - ArgoCD, Ingress, CertManager, ALB

# Get platform layer info
data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = "med-app-remotestate"
    key    = "med-app/dev/platform.tfstate"
    region = "us-east-1"
  }
}

# ALB Module (optional - uncomment when ready)
# module "alb" {
#   source = "../../../modules/alb"
#
#   name              = "med-app-dev-alb"
#   internal          = false
#   subnet_ids        = data.terraform_remote_state.platform.outputs.public_subnet_ids
#   security_group_ids = [aws_security_group.alb.id]
#   vpc_id            = data.terraform_remote_state.platform.outputs.vpc_id
#   certificate_arn   = var.certificate_arn
# }

