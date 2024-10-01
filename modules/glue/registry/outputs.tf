output "registry_id" {
  description = "Glue registry ID"
  value       = module.glue_registry.id
}

output "registry_name" {
  description = "Glue registry name"
  value       = module.glue_registry.name
}

output "registry_arn" {
  description = "Glue registry ARN"
  value       = module.glue_registry.arn
}
