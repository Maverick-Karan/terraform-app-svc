# ElastiCache Redis Module

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = var.replication_group_id
  description                = var.description
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = var.security_group_ids
  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.auth_token

  tags = merge(
    var.tags,
    {
      Name = var.replication_group_id
    }
  )
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.replication_group_id}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.replication_group_id}-params"
  family = "redis${replace(var.engine_version, "/\\.[0-9]+$/", "")}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags
}

