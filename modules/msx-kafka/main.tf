# MSK (Managed Streaming for Kafka) Module

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_msk_cluster" "main" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.subnet_ids
    security_groups = var.security_group_ids
    storage_info {
      ebs_storage_info {
        volume_size = var.volume_size
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_id = var.kms_key_id
    encryption_in_transit {
      client_broker = var.encryption_in_transit
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = var.enable_sasl_iam
    }
    tls {
      certificate_authority_arns = var.certificate_authority_arns
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

