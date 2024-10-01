output "additional_users" {
  value       = local.enabled ? values(module.additional_users)[*].db_user : null
  description = "Additional users"
}

output "additional_databases" {
  value       = local.enabled ? values(postgresql_database.additional)[*].name : null
  description = "Additional databases"
}

output "additional_schemas" {
  value       = local.enabled ? values(postgresql_schema.additional)[*].name : null
  description = "Additional schemas"
}

output "additional_grants" {
  value       = keys(module.additional_grants)
  description = "Additional grants"
}
