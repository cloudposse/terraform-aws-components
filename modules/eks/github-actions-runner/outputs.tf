output "release_name" {
  value       = var.controller_chart_release_name
  description = "Name of the release"
}

output "release_namespace" {
  value       = var.controller_chart_namespace
  description = "Namespace of the release"
}

output "service_account_role_arn" {
  value       = module.actions_runner_controller.service_account_role_arn
  description = "Service Account role ARN"
}

output "kms_key_arn" {
  value       = join("", aws_kms_key.github_action_runner.*.arn)
  description = "KMS key ARN"
}

output "kms_alias" {
  value       = join("", aws_kms_alias.github_action_runner.*.name)
  description = "KMS alias"
}
