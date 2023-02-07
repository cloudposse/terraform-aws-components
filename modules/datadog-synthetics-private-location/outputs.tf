output "synthetics_private_location_id" {
  value       = join("", datadog_synthetics_private_location.this.*.id)
  description = "Synthetics private location ID"
}

output "metadata" {
  value       = local.enabled ? module.datadog_synthetics_private_location.metadata : null
  description = "Block status of the deployed release"
}
