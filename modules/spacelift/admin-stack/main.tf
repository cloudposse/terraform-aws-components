locals {
  enabled                 = module.this.enabled
  create_root_admin_stack = local.enabled && var.root_admin_stack
  root_admin_stack_name   = local.create_root_admin_stack ? keys(module.root_admin_stack_config.spacelift_stacks)[0] : null
  root_admin_stack_config = local.create_root_admin_stack ? module.root_admin_stack_config.spacelift_stacks[local.root_admin_stack_name] : null

  # Create a map of all the policies {policy_name = policy_id}
  policies = { for k, v in data.spacelift_policies.this.policies : v.name => v.id }
}

data "spacelift_policies" "this" {}
