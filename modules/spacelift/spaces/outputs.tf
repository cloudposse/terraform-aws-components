output "spaces" {
  value       = local.enabled ? local.spaces : {}
  description = "The spaces created by this component"
}

output "policies" {
  value       = local.enabled ? local.policies : {}
  description = "The policies created by this component"
}
