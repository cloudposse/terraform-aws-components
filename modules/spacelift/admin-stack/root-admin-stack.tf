# The root admin stack is a special stack that is used to manage all of the other admin stacks in the the Spacelift
# organization. This stack is denoted by setting the root_administrative property to true in the atmos config. Only one
# such stack is allowed in the Spacelift organization.
module "root_admin_stack_config" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config"
  version = "1.5.0"

  enabled = local.create_root_admin_stack

  context_filters = {
    root_administrative = true
  }
}

# This gets the atmos stack config for all of the administrative stacks
module "all_admin_stacks_config" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config"
  version = "1.5.0"

  enabled = local.create_root_admin_stack

  context_filters = {
    administrative = true
  }
}

module "root_admin_stack" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stack"
  version = "1.5.0"

  enabled = local.create_root_admin_stack

  # Only the following attributes are available in `local.root_admin_stack_config`
  # component, base_component, stack, imports, deps, deps_all, vars, settings, env, inheritance, metadata, backend_type, backend, workspace, labels
  # They are in the outputs from the module https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/tree/main/modules/spacelift-stacks-from-atmos-config
  # The rest are configured in `settings.spacelift` or `vars` for each component, and should be accessed by `each.value.settings.spacelift` and `each.value.vars`

  atmos_stack_name    = try(local.root_admin_stack_config.stack, null)
  component_env       = try(local.root_admin_stack_config.env, var.component_env)
  component_name      = try(local.root_admin_stack_config.component, null)
  component_root      = try(join("/", [var.component_root, local.root_admin_stack_config.metadata.component]), null)
  component_vars      = try(local.root_admin_stack_config.vars, var.component_vars)
  terraform_workspace = try(local.root_admin_stack_config.workspace, var.terraform_workspace)
  labels              = concat(try(local.root_admin_stack_config.labels, []), try(var.labels, []))

  administrative                          = true
  after_apply                             = try(local.root_admin_stack_config.settings.spacelift.after_apply, [])
  after_destroy                           = try(local.root_admin_stack_config.settings.spacelift.after_destroy, [])
  after_init                              = try(local.root_admin_stack_config.settings.spacelift.after_init, [])
  after_perform                           = try(local.root_admin_stack_config.settings.spacelift.after_perform, [])
  after_plan                              = try(local.root_admin_stack_config.settings.spacelift.after_plan, [])
  autodeploy                              = try(local.root_admin_stack_config.settings.spacelift.autodeploy, var.autodeploy)
  autoretry                               = try(local.root_admin_stack_config.settings.spacelift.autoretry, var.autoretry)
  aws_role_enabled                        = try(local.root_admin_stack_config.settings.spacelift.aws_role_enabled, var.aws_role_enabled)
  aws_role_arn                            = try(local.root_admin_stack_config.settings.spacelift.aws_role_arn, var.aws_role_arn)
  aws_role_external_id                    = try(local.root_admin_stack_config.settings.spacelift.aws_role_external_id, var.aws_role_external_id)
  aws_role_generate_credentials_in_worker = try(local.root_admin_stack_config.settings.spacelift.aws_role_generate_credentials_in_worker, var.aws_role_generate_credentials_in_worker)
  before_apply                            = try(local.root_admin_stack_config.settings.spacelift.before_apply, [])
  before_destroy                          = try(local.root_admin_stack_config.settings.spacelift.before_destroy, [])
  before_init                             = try(local.root_admin_stack_config.settings.spacelift.before_init, [])
  before_perform                          = try(local.root_admin_stack_config.settings.spacelift.before_perform, [])
  before_plan                             = try(local.root_admin_stack_config.settings.spacelift.before_plan, [])
  branch                                  = try(local.root_admin_stack_config.settings.spacelift.branch, var.branch)
  commit_sha                              = var.commit_sha != null ? var.commit_sha : try(local.root_admin_stack_config.settings.spacelift.commit_sha, null)
  context_attachments                     = try(local.root_admin_stack_config.settings.spacelift.context_attachments, var.context_attachments)
  description                             = try(local.root_admin_stack_config.settings.spacelift.description, var.description)
  drift_detection_enabled                 = try(local.root_admin_stack_config.settings.spacelift.drift_detection_enabled, var.drift_detection_enabled)
  drift_detection_reconcile               = try(local.root_admin_stack_config.settings.spacelift.drift_detection_reconcile, var.drift_detection_reconcile)
  drift_detection_schedule                = try(local.root_admin_stack_config.settings.spacelift.drift_detection_schedule, var.drift_detection_schedule)
  drift_detection_timezone                = try(local.root_admin_stack_config.settings.spacelift.drift_detection_timezone, var.drift_detection_timezone)
  local_preview_enabled                   = try(local.root_admin_stack_config.settings.spacelift.local_preview_enabled, var.local_preview_enabled)
  manage_state                            = try(local.root_admin_stack_config.settings.spacelift.manage_state, var.manage_state)
  protect_from_deletion                   = try(local.root_admin_stack_config.settings.spacelift.protect_from_deletion, var.protect_from_deletion)
  repository                              = var.repository
  runner_image                            = try(local.root_admin_stack_config.settings.spacelift.runner_image, var.runner_image)
  space_id                                = var.space_id
  spacelift_run_enabled                   = coalesce(try(local.root_admin_stack_config.settings.spacelift.spacelift_run_enabled, null), var.spacelift_run_enabled)
  spacelift_stack_dependency_enabled      = try(local.root_admin_stack_config.settings.spacelift.spacelift_stack_dependency_enabled, var.spacelift_stack_dependency_enabled)
  stack_destructor_enabled                = try(local.root_admin_stack_config.settings.spacelift.stack_destructor_enabled, var.stack_destructor_enabled)
  stack_name                              = var.stack_name != null ? var.stack_name : local.root_admin_stack_name
  terraform_smart_sanitization            = try(local.root_admin_stack_config.settings.spacelift.terraform_smart_sanitization, var.terraform_smart_sanitization)
  terraform_version                       = lookup(var.terraform_version_map, try(local.root_admin_stack_config.settings.spacelift.terraform_version, ""), var.terraform_version)
  webhook_enabled                         = try(local.root_admin_stack_config.settings.spacelift.webhook_enabled, var.webhook_enabled)
  webhook_endpoint                        = try(local.root_admin_stack_config.settings.spacelift.webhook_endpoint, var.webhook_endpoint)
  webhook_secret                          = try(local.root_admin_stack_config.settings.spacelift.webhook_secret, var.webhook_secret)
  worker_pool_id                          = local.worker_pools[var.worker_pool_name]

  azure_devops         = try(local.root_admin_stack_config.settings.spacelift.azure_devops, var.azure_devops)
  bitbucket_cloud      = try(local.root_admin_stack_config.settings.spacelift.bitbucket_cloud, var.bitbucket_cloud)
  bitbucket_datacenter = try(local.root_admin_stack_config.settings.spacelift.bitbucket_datacenter, var.bitbucket_datacenter)
  cloudformation       = try(local.root_admin_stack_config.settings.spacelift.cloudformation, var.cloudformation)
  github_enterprise    = try(local.root_admin_stack_config.settings.spacelift.github_enterprise, var.github_enterprise)
  gitlab               = try(local.root_admin_stack_config.settings.spacelift.gitlab, var.gitlab)
  pulumi               = try(local.root_admin_stack_config.settings.spacelift.pulumi, var.pulumi)
  showcase             = try(local.root_admin_stack_config.settings.spacelift.showcase, var.showcase)

  depends_on = [
    null_resource.spaces_precondition,
    null_resource.workers_precondition
  ]

  context = module.this.context
}

resource "spacelift_policy_attachment" "root" {
  for_each  = var.root_stack_policy_attachments
  policy_id = local.policies[each.key]
  stack_id  = module.root_admin_stack.id
}
