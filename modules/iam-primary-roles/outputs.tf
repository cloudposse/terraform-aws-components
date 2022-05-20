output "role_name_role_arn_map" {
  value       = { for key, value in local.roles_config : key => aws_iam_role.default[key].arn }
  description = "Map of role names to role ARNs"
}

output "role_names" {
  value       = values(aws_iam_role.default)[*].name
  description = "List of role names"
}

output "role_arns" {
  value       = values(aws_iam_role.default)[*].arn
  description = "List of role ARNs"
}

output "primary_roles_config" {
  value       = var.primary_roles_config
  description = "Map of role config with name, target arn, and description"
}

output "delegated_role_name_role_arn_map" {
  value       = { for key, value in var.delegated_roles_config : key => aws_iam_role.default[key].arn }
  description = "Map of delegated role names to role ARNs"
}

output "delegated_role_names" {
  value       = [for key, value in var.delegated_roles_config : aws_iam_role.default[key].name]
  description = "List of delegated role names"
}

output "delegated_role_arns" {
  value       = [for key, value in var.delegated_roles_config : aws_iam_role.default[key].arn]
  description = "List of delegated role ARNs"
}

output "delegated_roles_config" {
  value       = var.delegated_roles_config
  description = "Map of delegated role config with name, target arn, and description"
}
