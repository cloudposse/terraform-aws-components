output "cert_manager_metadata" {
  value       = module.cert_manager.metadata
  description = "Block status of the deployed release"
}

output "cert_manager_issuer_metadata" {
  value       = module.cert_manager_issuer.metadata
  description = "Block status of the deployed release"
}

