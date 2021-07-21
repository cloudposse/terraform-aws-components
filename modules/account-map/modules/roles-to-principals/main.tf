module "forced" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.14.0"

  component               = "account-map"
  privileged              = var.privileged
  environment             = var.global_environment_name
  stack_config_local_path = "../../../stacks"
  stage                   = var.root_account_stage_name

  context = module.forced.context
}

locals {
  principals = distinct(compact(flatten([for acct, v in var.role_map : (
    contains(v, "*") ? [module.account_map.outputs.full_account_map[acct]] :
    [
      for role in v : format(var.iam_role_arn_template,
        module.account_map.outputs.full_account_map[acct],
        module.forced.namespace,
        var.global_environment_name,
        acct,
        role
      )
    ]
  )])))
}
