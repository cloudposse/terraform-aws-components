output "metadata" {
  value       = local.enabled ? helm_release.this[0].metadata : null
  description = "Block status of the deployed release"
}
