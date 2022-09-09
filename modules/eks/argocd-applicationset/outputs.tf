output "metadata" {
  value       = module.argocd_applicationset.metadata
  description = "Block status of the deployed release"
}
