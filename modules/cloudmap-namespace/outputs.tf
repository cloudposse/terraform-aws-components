output "name" {
  value       = module.this.id
  description = "The name of the namespace"
}

output "id" {
  value       = coalesce(one(aws_service_discovery_http_namespace.default[*].id), one(aws_service_discovery_private_dns_namespace.default[*].id), one(aws_service_discovery_public_dns_namespace.default[*].id))
  description = "The ID of the namespace"
}

output "arn" {
  value       = coalesce(one(aws_service_discovery_http_namespace.default[*].arn), one(aws_service_discovery_private_dns_namespace.default[*].arn), one(aws_service_discovery_public_dns_namespace.default[*].arn))
  description = "The ARN of the namespace"
}
