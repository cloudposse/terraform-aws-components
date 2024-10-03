output "additional_users" {
  value       = { for k, v in var.additional_users : k => module.additional_users[k] }
  description = "Additional DB users created"
}

output "additional_grants" {
  value       = keys(module.additional_grants)
  description = "Additional DB users created"
}
