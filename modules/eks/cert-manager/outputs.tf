output "cert_manager_metadata" {
  value       = try(one(module.cert_manager.metadata), null)
  description = "Block status of the deployed release"
}

output "cert_manager_issuer_metadata" {
  value       = try(one(module.cert_manager_issuer.metadata), null)
  description = "Block status of the deployed release"
}
