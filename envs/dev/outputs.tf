output "ecr_repo_urls" {
  description = "ECR repository URLs for all services"
  value       = module.ecr.ecr_repo_urls
}

output "ecr_repo_arns" {
  description = "ECR repository ARNs for all services"
  value       = module.ecr.ecr_repo_arns
}

output "ecr_repo_names" {
  description = "ECR repository names for all services"
  value       = module.ecr.ecr_repo_names
}

output "ecr_registry_id" {
  description = "ECR registry ID"
  value       = module.ecr.ecr_registry_id
}

