output "spacelift_worker_pool_controller_metadata" {
  value       = module.spacelift_worker_pool_controller.metadata
  description = "Block status of the deployed Spacelift worker pool Kubernetes controller"
}
