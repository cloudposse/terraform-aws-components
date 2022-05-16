output "role_name_role_arn_map" {
  description = "Map of role names to role ARNs"
  value       = { for key, value in local.roles_config : key => aws_iam_role.default[key].arn }
}

output "role_names" {
  description = "List of role names"
  value       = values(aws_iam_role.default)[*].name
}

output "role_arns" {
  description = "List of role ARNs"
  value       = values(aws_iam_role.default)[*].arn
}

output "primary_roles_config" {
  description = "Map of role config with name, target arn, and description"
  value       = var.primary_roles_config
}

output "delegated_role_name_role_arn_map" {
  description = "Map of delegated role names to role ARNs"
  value       = { for key, value in var.delegated_roles_config : key => aws_iam_role.default[key].arn }
}

output "delegated_role_names" {
  description = "List of delegated role names"
  value       = [for key, value in var.delegated_roles_config : aws_iam_role.default[key].name]
}

output "delegated_role_arns" {
  description = "List of delegated role ARNs"
  value       = [for key, value in var.delegated_roles_config : aws_iam_role.default[key].arn]
}

output "delegated_roles_config" {
  description = "Map of delegated role config with name, target arn, and description"
  value       = var.delegated_roles_config
}
