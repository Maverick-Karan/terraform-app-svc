output "ecr_repo_urls" {
  description = "Map of service names to ECR repository URLs"
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}

output "ecr_repo_arns" {
  description = "Map of service names to ECR repository ARNs"
  value       = { for k, v in aws_ecr_repository.repos : k => v.arn }
}

output "ecr_repo_names" {
  description = "Map of service names to ECR repository names"
  value       = { for k, v in aws_ecr_repository.repos : k => v.name }
}

output "ecr_registry_id" {
  description = "The registry ID where the repositories are created"
  value       = try(values(aws_ecr_repository.repos)[0].registry_id, null)
}

