output "node_pools" {
  value       = kubernetes_manifest.node_pool
  description = "Deployed Karpenter NodePool resources"
}

output "node_class" {
  value       = kubernetes_manifest.node_class
  description = "Deployed Karpenter NodeClass resources"
}
