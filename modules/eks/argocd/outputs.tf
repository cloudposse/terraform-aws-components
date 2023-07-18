output "metadata" {
  value       = module.argocd.metadata
  description = "Block status of the deployed ArgoCD release"
}

output "argocd_apps_metadata" {
  value       = module.argocd_apps.metadata
  description = "Block status of the deployed ArgoCD apps release"
}
