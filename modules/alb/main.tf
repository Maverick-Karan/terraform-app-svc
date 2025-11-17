# Application Load Balancer Module

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_enabled
    prefix  = var.access_logs_prefix
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

resource "aws_lb_listener" "http" {
  count = var.redirect_http_to_https ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "main" {
  count = length(var.target_groups)

  name        = "${var.name}-${var.target_groups[count.index].name}"
  port        = var.target_groups[count.index].port
  protocol    = var.target_groups[count.index].protocol
  vpc_id      = var.vpc_id
  target_type = var.target_groups[count.index].target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.target_groups[count.index].health_check.healthy_threshold
    unhealthy_threshold = var.target_groups[count.index].health_check.unhealthy_threshold
    timeout             = var.target_groups[count.index].health_check.timeout
    interval            = var.target_groups[count.index].health_check.interval
    path                = var.target_groups[count.index].health_check.path
    protocol            = var.target_groups[count.index].health_check.protocol
    matcher             = var.target_groups[count.index].health_check.matcher
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${var.target_groups[count.index].name}"
    }
  )
}

