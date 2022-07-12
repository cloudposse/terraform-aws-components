output "role_name_role_arn_map" {
  description = "Map of role names to role ARNs"
  value       = { for key, value in local.roles_config : key => try(aws_iam_role.default[key].arn, null) }
}

