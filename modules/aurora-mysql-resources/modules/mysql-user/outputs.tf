output "notice" {
  value       = local.save_password_in_ssm ? "Password for user ${local.db_user} is stored in SSM under ${local.db_password_key}" : null
  description = "Note to user"
}

output "password_ssm_key" {
  value       = local.save_password_in_ssm ? local.db_password_key : null
  description = "SSM key under which user password is stored"
}

output "db_user" {
  value       = local.db_user
  description = "DB user name"
}
