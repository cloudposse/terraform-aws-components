output "spaces" {
  description = "The spaces created by this component"
  value       = local.enabled ? local.spaces : {}
}

output "policies" {
  description = "The policies created by this component"
  value       = local.enabled ? local.policies : {}
}
