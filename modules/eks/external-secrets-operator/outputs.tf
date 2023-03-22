output "metadata" {
  value       = try(one(module.external_secrets_operator.metadata), null)
  description = "Block status of the deployed release"
}
