output "metadata" {
  value       = try(one(module.keda.metadata), null)
  description = "Block status of the deployed release"
}
