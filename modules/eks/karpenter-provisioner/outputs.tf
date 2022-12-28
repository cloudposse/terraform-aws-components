output "provisioners" {
  value       = kubernetes_manifest.provisioner
  description = "Deployed Karpenter provisioners"
}

output "providers" {
  value       = kubernetes_manifest.provider
  description = "Deployed Karpenter AWSNodeTemplates"
}
