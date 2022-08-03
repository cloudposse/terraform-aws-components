output "provisioners" {
  value       = kubernetes_manifest.default
  description = "Deployed Karpenter provisioners"
}
