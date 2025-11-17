variable "cluster_name" {
  description = "MSK cluster name"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version"
  type        = string
  default     = "3.5.1"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes"
  type        = number
}

variable "instance_type" {
  description = "Instance type for brokers"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for brokers"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 100
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "encryption_in_transit" {
  description = "Encryption in transit setting"
  type        = string
  default     = "TLS"
}

variable "enable_sasl_iam" {
  description = "Enable SASL/IAM authentication"
  type        = bool
  default     = true
}

variable "certificate_authority_arns" {
  description = "Certificate authority ARNs for TLS"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

