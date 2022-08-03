output "metadata" {
  value       = module.cluster_autoscaler.metadata
  description = "Block status of the deployed release"
}

output "service_account_role_name" {
  value       = module.cluster_autoscaler.service_account_role_name
  description = "Outputs from `eks-iam-role` module"
}
