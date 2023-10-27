output "root_stack_id" {
  description = "The stack id"
  value       = local.enabled && local.create_root_admin_stack ? module.root_admin_stack.id : ""
}

output "root_stack" {
  description = "The root stack, if enabled and created by this component"
  value       = local.enabled && local.create_root_admin_stack ? module.root_admin_stack : null
  sensitive   = true
}

output "child_stacks" {
  description = "All children stacks managed by this component"
  value       = local.enabled ? values(module.child_stack)[*] : []
  sensitive   = true
}
