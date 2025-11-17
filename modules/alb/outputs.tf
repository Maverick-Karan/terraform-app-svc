output "lb_id" {
  description = "Load balancer ID"
  value       = aws_lb.main.id
}

output "lb_arn" {
  description = "Load balancer ARN"
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "Load balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "Load balancer zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arns" {
  description = "Target group ARNs"
  value       = aws_lb_target_group.main[*].arn
}

