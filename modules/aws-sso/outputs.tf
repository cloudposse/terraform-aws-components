output "permission_sets" {
  value       = module.permission_sets.permission_sets
  description = "Permission sets"
}

output "sso_account_assignments" {
  value       = module.sso_account_assignments.assignments
  description = "SSO account assignments"
}
