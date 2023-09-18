locals {
  child_stacks = {
    for k, v in module.child_stacks_config.spacelift_stacks : k => v
    if local.enabled == true &&
    try(v.settings.spacelift.workspace_enabled, false) == true
  }

  child_stack_policies = {
    for k, v in module.all_admin_stacks_config.spacelift_stacks : k => v.vars.child_policy_attachments
    if local.enabled == true &&
    try(v.settings.spacelift.workspace_enabled, false) == true &&
    try(v.vars.child_policy_attachments, null) != null
  }

  child_policies    = local.create_root_admin_stack ? var.child_policy_attachments : try(local.child_stack_policies[local.managed_by], null)
  child_policy_ids  = try([for item in local.child_policies : local.policies[item]], [])
  admin_stack_label = try([for item in var.labels : item if startswith(item, format("${var.admin_stack_label}:"))][0], null)
  managed_by        = local.create_root_admin_stack ? local.root_admin_stack_name : try(data.spacelift_stacks.this[0].stacks[0].name, null)
}

data "spacelift_stacks" "this" {
  count = (
    local.enabled &&
    local.create_root_admin_stack == false &&
    local.admin_stack_label != null
  ) ? 1 : 0
  labels {
    any_of = [local.admin_stack_label]
  }
}

# Ensure no stacks are configured to use public workers if they are not allowed
resource "null_resource" "child_stack_parent_precondition" {
  count = local.enabled ? 1 : 0
  lifecycle {
    precondition {
      condition     = local.create_root_admin_stack ? true : length(data.spacelift_stacks.this[0].stacks) > 0
      error_message = "Please apply this stack's parent before applying this stack."
    }
  }
}

# Get all of the stack configurations from the atmos config that matched the context_filters and create a stack
# for each one.
module "child_stacks_config" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config"
  version = "1.0.0"

  context_filters = var.context_filters

  context = module.this.context
}

module "child_stack" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stack"
  version = "1.0.0"

  for_each = local.child_stacks
  depends_on = [
    null_resource.spaces_precondition,
    null_resource.workers_precondition,
    spacelift_policy_attachment.root,
    null_resource.child_stack_parent_precondition
  ]

  administrative                          = try(each.value.settings.spacelift.administrative, false)
  after_apply                             = try(each.value.settings.spacelift.after_apply, [])
  after_destroy                           = try(each.value.settings.spacelift.after_destroy, [])
  after_init                              = try(each.value.settings.spacelift.after_init, [])
  after_perform                           = try(each.value.settings.spacelift.after_perform, [])
  after_plan                              = try(each.value.settings.spacelift.after_plan, [])
  atmos_stack_name                        = try(each.value.stack, null)
  autodeploy                              = try(each.value.settings.spacelift.autodeploy, false)
  autoretry                               = try(each.value.settings.spacelift.autoretry, false)
  aws_role_enabled                        = try(each.value.settings.aws_role_enabled, var.aws_role_enabled)
  aws_role_arn                            = try(each.value.settings.aws_role_arn, var.aws_role_arn)
  aws_role_external_id                    = try(each.value.settings.aws_role_external_id, var.aws_role_external_id)
  aws_role_generate_credentials_in_worker = try(each.value.settings.aws_role_generate_credentials_in_worker, var.aws_role_generate_credentials_in_worker)
  before_apply                            = try(each.value.settings.spacelift.before_apply, [])
  before_destroy                          = try(each.value.settings.spacelift.before_destroy, [])
  before_init                             = try(each.value.settings.spacelift.before_init, [])
  before_perform                          = try(each.value.settings.spacelift.before_perform, [])
  before_plan                             = try(each.value.settings.spacelift.before_plan, [])
  branch                                  = try(each.value.branch, var.branch)
  commit_sha                              = var.commit_sha != null ? var.commit_sha : try(each.value.commit_sha, null)
  component_env                           = try(each.value.env, {})
  component_name                          = try(each.value.component, null)
  component_root                          = try(join("/", [var.component_root, try(each.value.metadata.component, each.value.component)]))
  component_vars                          = try(each.value.vars, null)
  context_attachments                     = try(each.value.context_attachments, [])
  description                             = try(each.value.description, var.description)
  drift_detection_enabled                 = try(each.value.settings.spacelift.drift_detection_enabled, var.drift_detection_enabled)
  drift_detection_reconcile               = try(each.value.settings.spacelift.drift_detection_reconcile, var.drift_detection_reconcile)
  drift_detection_schedule                = try(each.value.settings.spacelift.drift_detection_schedule, var.drift_detection_schedule)
  drift_detection_timezone                = try(each.value.settings.spacelift.drift_detection_timezone, var.drift_detection_timezone)
  labels = concat(
    try(each.value.labels, []),
    try(each.value.vars.labels, []),
    ["managed-by:${local.managed_by}"],
    local.create_root_admin_stack ? ["depends-on:${local.root_admin_stack_name}", ""] : []
  )
  local_preview_enabled        = try(each.value.local_preview_enabled, var.local_preview_enabled)
  manage_state                 = try(each.value.manage_state, var.manage_state)
  policy_ids                   = try(local.child_policy_ids, [])
  protect_from_deletion        = try(each.value.settings.spacelift.protect_from_deletion, false)
  repository                   = var.repository
  runner_image                 = try(each.value.settings.spacelift.runner_image, var.runner_image)
  space_id                     = local.spaces[each.value.settings.spacelift.space_name]
  spacelift_run_enabled        = try(each.value.settings.spacelift.spacelift_run_enabled, var.spacelift_run_enabled)
  stack_destructor_enabled     = try(each.value.settings.spacelift.stack_destructor_enabled, var.stack_destructor_enabled)
  stack_name                   = try(each.value.settings.spacelift.stack_name, each.key)
  terraform_smart_sanitization = try(each.value.terraform_smart_sanitization, false)
  terraform_version            = lookup(var.terraform_version_map, try(each.value.terraform_version, ""), var.terraform_version)
  terraform_workspace          = try(each.value.workspace, null)
  webhook_enabled              = try(each.value.webhook_enabled, var.webhook_enabled)
  webhook_endpoint             = try(each.value.webhook_endpoint, var.webhook_endpoint)
  webhook_secret               = try(each.value.webhook_secret, var.webhook_secret)
  worker_pool_id               = try(local.worker_pools[each.value.worker_pool_name], local.worker_pools[var.worker_pool_name])

  azure_devops         = try(each.value.azure_devops, null)
  bitbucket_cloud      = try(each.value.bitbucket_cloud, null)
  bitbucket_datacenter = try(each.value.bitbucket_datacenter, null)
  cloudformation       = try(each.value.cloudformation, null)
  github_enterprise    = try(local.root_admin_stack_config.settings.spacelift.github_enterprise, null)
  gitlab               = try(local.root_admin_stack_config.settings.spacelift.gitlab, null)
  pulumi               = try(local.root_admin_stack_config.settings.spacelift.pulumi, null)
  showcase             = try(local.root_admin_stack_config.settings.spacelift.showcase, null)

  context = module.this.context
}
