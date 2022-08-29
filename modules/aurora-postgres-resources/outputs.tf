output "additional_users" {
  value       = local.enabled ? values(module.additional_users)[*].db_user : null
  description = "Additional users"
}

output "read_only_users" {
  value       = local.enabled ? local.sanitized_ro_users : null
  description = "Read-only users"
}

output "additional_databases" {
  value       = local.enabled ? values(postgresql_database.additional)[*].name : null
  description = "Additional databases"
}
