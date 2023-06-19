# The root admin stack is a special stack that is used to manage all of the other admin stacks in the the Spacelift
# organization. This stack is denoted by setting the root_administrative property to true in the atmos config. Only one
# such stack is allowed in the Spacelift organization.
module "root_admin_stack_config" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config"
  version = "1.0.0"

  enabled = local.create_root_admin_stack

  context_filters = {
    root_administrative = true
  }
}

# This gets the atmos stack config for all of the administrative stacks
module "all_admin_stacks_config" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config"
  version = "1.0.0"

  enabled = local.create_root_admin_stack
  context_filters = {
    administrative = true
  }
}

module "root_admin_stack" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stack"
  version = "1.0.0"

  enabled    = local.create_root_admin_stack
  depends_on = [null_resource.spaces_precondition, null_resource.workers_precondition]

  administrative                          = true
  after_apply                             = try(local.root_admin_stack_config.settings.spacelift.after_apply, [])
  after_destroy                           = try(local.root_admin_stack_config.settings.spacelift.after_destroy, [])
  after_init                              = try(local.root_admin_stack_config.settings.spacelift.after_init, [])
  after_perform                           = try(local.root_admin_stack_config.settings.spacelift.after_perform, [])
  after_plan                              = try(local.root_admin_stack_config.settings.spacelift.after_plan, [])
  atmos_stack_name                        = try(local.root_admin_stack_config.stack, null)
  autodeploy                              = try(local.root_admin_stack_config.settings.spacelift.autodeploy, false)
  autoretry                               = try(local.root_admin_stack_config.settings.spacelift.autoretry, false)
  aws_role_enabled                        = try(local.root_admin_stack_config.settings.aws_role_enabled, var.aws_role_enabled)
  aws_role_arn                            = try(local.root_admin_stack_config.settings.aws_role_arn, var.aws_role_arn)
  aws_role_external_id                    = try(local.root_admin_stack_config.settings.aws_role_external_id, var.aws_role_external_id)
  aws_role_generate_credentials_in_worker = try(local.root_admin_stack_config.settings.aws_role_generate_credentials_in_worker, var.aws_role_generate_credentials_in_worker)
  before_apply                            = try(local.root_admin_stack_config.settings.spacelift.before_apply, [])
  before_destroy                          = try(local.root_admin_stack_config.settings.spacelift.before_destroy, [])
  before_init                             = try(local.root_admin_stack_config.settings.spacelift.before_init, [])
  before_perform                          = try(local.root_admin_stack_config.settings.spacelift.before_perform, [])
  before_plan                             = try(local.root_admin_stack_config.settings.spacelift.before_plan, [])
  branch                                  = try(local.root_admin_stack_config.branch, var.branch)
  commit_sha                              = var.commit_sha != null ? var.commit_sha : try(local.root_admin_stack_config.commit_sha, null)
  component_env                           = try(local.root_admin_stack_config.env, {})
  component_name                          = try(local.root_admin_stack_config.component, null)
  component_root                          = try(join("/", [var.component_root, local.root_admin_stack_config.metadata.component]), null)
  component_vars                          = try(local.root_admin_stack_config.vars, null)
  context_attachments                     = try(local.root_admin_stack_config.context_attachments, [])
  description                             = try(local.root_admin_stack_config.description, null)
  drift_detection_enabled                 = try(local.root_admin_stack_config.settings.spacelift.drift_detection_enabled, var.drift_detection_enabled)
  drift_detection_reconcile               = try(local.root_admin_stack_config.settings.spacelift.drift_detection_reconcile, var.drift_detection_reconcile)
  drift_detection_schedule                = try(local.root_admin_stack_config.settings.spacelift.drift_detection_schedule, var.drift_detection_schedule)
  drift_detection_timezone                = try(local.root_admin_stack_config.settings.spacelift.drift_detection_timezone, var.drift_detection_timezone)
  labels                                  = concat(try(local.root_admin_stack_config.labels, []), try(var.labels, []))
  local_preview_enabled                   = try(local.root_admin_stack_config.local_preview_enabled, var.local_preview_enabled)
  manage_state                            = try(local.root_admin_stack_config.manage_state, var.manage_state)
  protect_from_deletion                   = try(local.root_admin_stack_config.settings.spacelift.protect_from_deletion, false)
  repository                              = var.repository
  runner_image                            = try(local.root_admin_stack_config.settings.spacelift.runner_image, var.runner_image)
  space_id                                = "root"
  spacelift_run_enabled                   = coalesce(try(local.root_admin_stack_config.settings.spacelift.spacelift_run_enabled, null), var.spacelift_run_enabled)
  stack_destructor_enabled                = try(local.root_admin_stack_config.settings.spacelift.stack_destructor_enabled, var.stack_destructor_enabled)
  stack_name                              = var.stack_name != null ? var.stack_name : local.root_admin_stack_name
  terraform_smart_sanitization            = try(local.root_admin_stack_config.terraform_smart_sanitization, false)
  terraform_version                       = lookup(var.terraform_version_map, try(local.root_admin_stack_config.terraform_version, ""), var.terraform_version)
  terraform_workspace                     = try(local.root_admin_stack_config.workspace, null)
  webhook_enabled                         = try(local.root_admin_stack_config.webhook_enabled, var.webhook_enabled)
  webhook_endpoint                        = try(local.root_admin_stack_config.webhook_endpoint, var.webhook_endpoint)
  webhook_secret                          = try(local.root_admin_stack_config.webhook_secret, var.webhook_secret)
  worker_pool_id                          = local.worker_pools[var.worker_pool_name]

  azure_devops         = try(local.root_admin_stack_config.azure_devops, null)
  bitbucket_cloud      = try(local.root_admin_stack_config.bitbucket_cloud, null)
  bitbucket_datacenter = try(local.root_admin_stack_config.bitbucket_datacenter, null)
  cloudformation       = try(local.root_admin_stack_config.cloudformation, null)
  github_enterprise    = try(local.root_admin_stack_config.github_enterprise, null)
  gitlab               = try(local.root_admin_stack_config.gitlab, null)
  pulumi               = try(local.root_admin_stack_config.pulumi, null)
  showcase             = try(local.root_admin_stack_config.showcase, null)
}

resource "spacelift_policy_attachment" "root" {
  for_each  = var.root_stack_policy_attachments
  policy_id = local.policies[each.key]
  stack_id  = module.root_admin_stack.id
}
