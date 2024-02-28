module "always" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # account_map must always be enabled, even for components that are disabled
  enabled = true

  context = module.this.context
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "account-map"
  privileged  = var.privileged
  tenant      = var.overridable_global_tenant_name
  environment = var.overridable_global_environment_name
  stage       = var.overridable_global_stage_name

  context = module.always.context
}

locals {
  aws_partition         = module.account_map.outputs.aws_partition
  team_ps_pattern       = var.overridable_team_permission_set_name_pattern
  identity_account_name = module.account_map.outputs.identity_account_account_name
  teams_from_role_map   = var.overridable_team_permission_sets_enabled ? try(var.role_map[local.identity_account_name], []) : []

  team_permission_set_name_map = {
    for team in distinct(concat(var.teams, local.teams_from_role_map)) : team => format(local.team_ps_pattern, replace(title(replace(team, "_", "-")), "-", ""))
  }
  permission_sets_from_team_roles = [for team in local.teams_from_role_map : local.team_permission_set_name_map[team]]

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
  # We ensure that the identity account is included in the map so that we can add the permission sets from team roles to it.
  permission_set_arn_like = distinct(compact(flatten([for acct, v in merge({ (local.identity_account_name) = [] }, var.permission_set_map) : formatlist(
    # Usually like:
    # arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_IdentityAdminRoleAccess_b68e107e9495e2fc
    # But sometimes AWS SSO ARN includes `/region/`, like:
    # arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_IdentityAdminRoleAccess_b68e107e9495e2fc
    # If trust polices get too large, some space can be saved by using `*` instead of `aws-reserved/sso.amazonaws.com*`
    format("arn:%s:iam::%s:role/aws-reserved/sso.amazonaws.com*/AWSReservedSSO_%%s_*", local.aws_partition, module.account_map.outputs.full_account_map[acct]),
    acct == local.identity_account_name ? distinct(concat(v, local.permission_sets_from_team_roles)) : v
  )])))
}
