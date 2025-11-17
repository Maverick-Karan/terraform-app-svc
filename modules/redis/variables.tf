variable "replication_group_id" {
  description = "Replication group identifier"
  type        = string
}

variable "description" {
  description = "Description of the replication group"
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Instance type for cache nodes"
  type        = string
}

variable "num_cache_clusters" {
  description = "Number of cache clusters"
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Enable multi-AZ"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnet IDs for subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "transit_encryption_enabled" {
  description = "Enable transit encryption"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Auth token for Redis"
  type        = string
  sensitive   = true
  default     = null
}

variable "parameters" {
  description = "List of Redis parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

