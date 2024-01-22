output "schema_id" {
  description = "Glue schema ID"
  value       = module.glue_schema.id
}

output "schema_name" {
  description = "Glue schema name"
  value       = module.glue_schema.name
}

output "schema_arn" {
  description = "Glue schema ARN"
  value       = module.glue_schema.arn
}

output "registry_name" {
  description = "Glue registry name"
  value       = module.glue_schema.registry_name
}

output "latest_schema_version" {
  description = "The latest version of the schema associated with the returned schema definition"
  value       = module.glue_schema.latest_schema_version
}

output "next_schema_version" {
  description = "The next version of the schema associated with the returned schema definition"
  value       = module.glue_schema.next_schema_version
}

output "schema_checkpoint" {
  description = "The version number of the checkpoint (the last time the compatibility mode was changed)"
  value       = module.glue_schema.schema_checkpoint
}
