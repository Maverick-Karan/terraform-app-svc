variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "List of microservices to create ECR repositories for"
  type        = list(string)
  default     = ["api-gateway", "auth-service", "patient-service", "billing-service", "analytics-service"]
}

