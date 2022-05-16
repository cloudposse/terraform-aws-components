module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component   = "account-map"
  privileged  = var.privileged
  tenant      = var.global_tenant_name
  environment = var.global_environment_name
  stage       = var.root_account_stage_name

  context = module.always.context
}

locals {
  principals = distinct(compact(flatten([for acct, v in var.role_map : (
    contains(v, "*") ? [format("arn:aws:iam::%s:root", module.account_map.outputs.full_account_map[acct])] :
    [
      for role in v : format(module.account_map.outputs.iam_role_arn_templates[acct], role)
    ]
  )])))

  # Support for AWS SSO Permission Sets
  permission_set_arn_like = distinct(compact(flatten([for acct, v in var.permission_set_map : formatlist(
    format("arn:aws:iam::%s:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_%%s_*", module.account_map.outputs.full_account_map[acct]),
  v)])))
}
