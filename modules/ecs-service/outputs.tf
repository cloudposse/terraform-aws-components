output "logs" {
  value       = one(module.logs[*])
  description = "Output of cloudwatch logs module"
}

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

output "rds_sg_id" {
  value       = local.rds_sg_id
  description = "Selected RDS SG ID"
}

output "lb_sg_id" {
  value       = local.lb_sg_id
  description = "Selected LB SG ID"
}

output "lb_arn" {
  value       = local.lb_arn
  description = "Selected LB ARN"
}

output "lb_listener_http" {
  value       = local.lb_listener_http_arn
  description = "Selected LB HTTP Listener"
}

output "lb_listener_https" {
  value       = local.lb_listener_https_arn
  description = "Selected LB HTTPS Listener"
}

output "full_domain" {
  value       = local.use_lb ? local.lb_fqdn : null
  description = "Domain to respond to GET requests"
}

output "full_urls" {
  value       = local.use_lb ? local.full_urls : []
  description = "The full urls to access the unauthenticated service paths"
}

output "environment_map" {
  value       = local.env_map_subst
  description = "Environment variables to pass to the container, this is a map of key/value pairs, where the key is `containerName,variableName`"
}

output "service_image" {
  value       = try(nonsensitive(local.containers.service.image), null)
  description = "The image of the service container"
}
