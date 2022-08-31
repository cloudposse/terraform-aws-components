output "team_name_role_arn_map" {
  value       = { for key, value in local.roles_config : key => aws_iam_role.default[key].arn }
  description = "Map of team names to role ARNs"
}

output "team_names" {
  value       = values(aws_iam_role.default)[*].name
  description = "List of team names"
}

output "role_arns" {
  value       = values(aws_iam_role.default)[*].arn
  description = "List of role ARNs"
}

output "teams_config" {
  value       = var.teams_config
  description = "Map of team config with name, target arn, and description"
}

