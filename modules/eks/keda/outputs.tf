## eks_iam_role

output "service_account_namespace" {
  value       = module.keda.service_account_namespace
  description = "Kubernetes Service Account namespace"
}

output "service_account_name" {
  value       = module.keda.service_account_name
  description = "Kubernetes Service Account name"
}

output "service_account_role_name" {
  value       = module.keda.service_account_role_name
  description = "IAM role name"
}

output "service_account_role_unique_id" {
  value       = module.keda.service_account_role_unique_id
  description = "IAM role unique ID"
}

output "service_account_role_arn" {
  value       = module.keda.service_account_role_arn
  description = "IAM role ARN"
}

output "service_account_policy_name" {
  value       = module.keda.service_account_policy_name
  description = "IAM policy name"
}

output "service_account_policy_id" {
  value       = module.keda.service_account_policy_id
  description = "IAM policy ID"
}

output "service_account_policy_arn" {
  value       = module.keda.service_account_policy_arn
  description = "IAM policy ARN"
}

## keda

output "metadata" {
  description = "Block status of the deployed release."
  value       = module.keda.metadata
}
