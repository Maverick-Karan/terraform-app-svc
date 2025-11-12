variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "services" {
  description = "List of microservices to create ECR repositories for"
  type        = list(string)
  default     = ["api-gateway", "auth-service", "patient-service", "billing-service", "analytics-service"]
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for ECR (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

