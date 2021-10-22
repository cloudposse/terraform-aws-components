output "release_name" {
  value       = join("", helm_release.actions_runner_controller.*.name)
  description = "Name of the release"
}

output "release_namespace" {
  value       = join("", helm_release.actions_runner_controller.*.namespace)
  description = "Namespace of the release"
}

output "service_account_role_arn" {
  value       = module.eks_iam_role.service_account_role_arn
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
