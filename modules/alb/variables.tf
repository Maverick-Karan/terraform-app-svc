variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs for the load balancer"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "access_logs_enabled" {
  description = "Enable access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 prefix for access logs"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP to HTTPS"
  type        = bool
  default     = true
}

variable "target_groups" {
  description = "List of target group configurations"
  type = list(object({
    name        = string
    port        = number
    protocol    = string
    target_type = string
    health_check = object({
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      interval            = number
      path                = string
      protocol            = string
      matcher             = string
    })
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

