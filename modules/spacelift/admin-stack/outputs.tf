output "root_stack_id" {
  description = "The stack id"
  value       = local.enabled && local.create_root_admin_stack ? module.root_admin_stack.id : null
}

output "root_stack" {
  value     = local.enabled && local.create_root_admin_stack ? module.root_admin_stack : null
  sensitive = true
}

output "child_stacks" {
  value     = local.enabled ? values(module.child_stack)[*] : null
  sensitive = true
}
