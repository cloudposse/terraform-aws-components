module "stack_config" {
  source  = "cloudposse/stack-config/yaml"
  version = "0.22.1"

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  config      = module.stack_config.config
  component   = "account-map"
  privileged  = var.privileged

  context = module.this.context
}

locals {
  principals = distinct(compact(flatten([for acct, v in var.role_map : (
    contains(v, "*") ? [module.account_map.outputs.full_account_map[acct]] : [
      for role in v : format(var.iam_role_arn_template,
        module.account_map.outputs.full_account_map[acct],
        module.this.namespace,
        module.this.environment,
        acct,
        role
      )
    ]
  )])))
}
