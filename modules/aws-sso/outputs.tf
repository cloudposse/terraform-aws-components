output "permission_sets" {
  value       = module.permission_sets.permission_sets
  description = "Permission sets"
}

output "sso_account_assignments" {
  value       = module.sso_account_assignments.assignments
  description = "SSO account assignments"
}

output "group_ids" {
  value       = { for group_key, group_output in aws_identitystore_group.manual : group_key => group_output.group_id }
  description = "Group IDs created for Identity Center"
}
