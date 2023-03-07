output "spacelift_space_names" {
  description = "List of Spacelift Space names created/managed by this component."
  value = concat(
    [for k, v in spacelift_space.stage : v.name],
    [for k, v in spacelift_space.account : v.name]
  )
}

output "okta_group_read_names" {
  description = "List of Okta group names created/managed by this component for Space read access."
  value       = [for k, v in okta_group.space_read : v.name]
}

output "okta_group_write_names" {
  description = "List of Okta group names created/managed by this component for Space write access."
  value       = [for k, v in okta_group.space_write : v.name]
}
