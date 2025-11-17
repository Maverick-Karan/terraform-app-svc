output "replication_group_id" {
  description = "Replication group ID"
  value       = aws_elasticache_replication_group.main.id
}

output "configuration_endpoint_address" {
  description = "Configuration endpoint address"
  value       = aws_elasticache_replication_group.main.configuration_endpoint_address
}

output "primary_endpoint_address" {
  description = "Primary endpoint address"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

