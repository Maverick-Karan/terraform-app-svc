variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    instance_types  = list(string)
    capacity_type   = string
    disk_size       = number
    ami_type        = string
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = number
    labels          = map(string)
  }))
  default = {}
}

variable "irsa_roles" {
  description = "Map of IRSA roles for service accounts"
  type = map(object({
    namespace      = string
    service_account = string
    policy_arn     = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

