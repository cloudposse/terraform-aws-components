output "role_name_role_arn_map" {
  value       = { for key, value in local.roles_config : key => try(aws_iam_role.default[key].arn, null) }
  description = "Map of role names to role ARNs"
}

output "role_long_name_policy_arn_map" {
  value       = { for key, value in local.roles_config : try(aws_iam_role.default[key].name, key) => try(aws_iam_role_policy_attachment.default[key].policy_arn, null) }
  description = "Map of role long names to attached IAM Policy ARNs"
}
