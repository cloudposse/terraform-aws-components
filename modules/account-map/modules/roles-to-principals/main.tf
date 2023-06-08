module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.2"

  component   = "account-map"
  privileged  = var.privileged
  tenant      = var.overridable_global_tenant_name
  environment = var.overridable_global_environment_name
  stage       = var.overridable_global_stage_name

  context = module.always.context
}

locals {
  aws_partition = module.account_map.outputs.aws_partition

  principals_map = { for acct, v in var.role_map : acct => (
    contains(v, "*") ? {
      "*" = format("arn:%s:iam::%s:root", local.aws_partition, module.account_map.outputs.full_account_map[acct])
    } :
    {
      for role in v : role => format(module.account_map.outputs.iam_role_arn_templates[acct], role)
    }
  ) }

  # This expression could be simplified, but then the order of principals would be different than in earlier versions, causing unnecessary plan changes.
  principals = distinct(compact(flatten([for acct, v in var.role_map : values(local.principals_map[acct])])))

  # Support for AWS SSO Permission Sets
  permission_set_arn_like = distinct(compact(flatten([for acct, v in var.permission_set_map : formatlist(
    # Usually like:
    # arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_IdentityAdminRoleAccess_b68e107e9495e2fc
    # But sometimes AWS SSO ARN includes `/region/`, like:
    # arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_IdentityAdminRoleAccess_b68e107e9495e2fc
    format("arn:%s:iam::%s:role/aws-reserved/sso.amazonaws.com*/AWSReservedSSO_%%s_*", local.aws_partition, module.account_map.outputs.full_account_map[acct]),
  v)])))
}
