output "deployment" {
  value       = kubernetes_deployment.operator
  description = "Tail scale operator deployment K8S resource"
}
