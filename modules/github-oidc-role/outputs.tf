#output "github_actions_iam_role_arn" {
#  value       = one(module.github_actions_role[*].arn)
#  description = "ARN of IAM role for GitHub Actions"
#}
#
#output "github_actions_iam_role_name" {
#  value       = one(module.github_actions_role[*].name)
#  description = "Name of IAM role for GitHub Actions"
#}


output "github_actions_iam_role_arn" {
  value       = one(aws_iam_role.github_actions[*].arn)
  description = "ARN of IAM role for GitHub Actions"
}

output "github_actions_iam_role_name" {
  value       = one(aws_iam_role.github_actions[*].name)
  description = "Name of IAM role for GitHub Actions"
}

output "test" {
  value = local.active_policy_map
}
