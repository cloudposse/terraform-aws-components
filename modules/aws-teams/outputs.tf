output "team_name_role_arn_map" {
  value       = local.role_name_role_arn_map
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


resource "local_file" "account_info" {
  content = templatefile("${path.module}/../aws-team-roles/iam-role-info.tftmpl", {
    role_name_map          = local.role_name_map
    role_name_role_arn_map = local.role_name_role_arn_map
    namespace              = module.this.namespace
  })
  filename = "${path.module}/../aws-team-roles/iam-role-info/${module.this.id}.sh"
}
