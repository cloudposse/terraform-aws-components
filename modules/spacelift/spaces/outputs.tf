output "spaces" {
  value = local.enabled ? local.spaces : {}
}

output "policies" {
  value = local.enabled ? local.policies : {}
}
