output "ecs_cluster_arn" {
  value       = local.ecs_cluster_arn
  description = "Selected ECS cluster ARN"
}

output "subnet_ids" {
  value       = local.subnet_ids
  description = "Selected subnet IDs"
}

output "vpc_id" {
  value       = local.vpc_id
  description = "Selected VPC ID"
}

output "vpc_sg_id" {
  value       = local.vpc_sg_id
  description = "Selected VPC SG ID"
}

output "lb_sg_id" {
  value       = local.lb_sg_id
  description = "Selected LB SG ID"
}

output "lb_arn" {
  value       = local.lb_arn
  description = "Selected LB ARN"
}

output "lb_listener_https" {
  value       = local.lb_listener_https_arn
  description = "Selected LB HTTPS Listener"
}
