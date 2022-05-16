module "always" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component   = "account-map"
  privileged  = var.privileged
  environment = var.global_environment_name
  stage       = var.root_account_stage_name

  context = module.always.context
}

locals {
  principals = distinct(compact(flatten([for acct, v in var.role_map : (
  contains(v, "*") ? [format("arn:%s:iam::%s:root", var.aws_partition, module.account_map.outputs.full_account_map[acct])] :
  [
  for role in v : format(var.iam_role_arn_template, var.aws_partition,
    module.account_map.outputs.full_account_map[acct],
    module.always.namespace,
    var.global_environment_name,
    acct,
    role
  )
  ]
  )])))

  permission_set_arn_like = distinct(compact(flatten([for acct, v in var.permission_set_map : formatlist(
    format("arn:%s:iam::%s:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_%%s_*", var.aws_partition, module.account_map.outputs.full_account_map[acct]),
    v)])))
}
