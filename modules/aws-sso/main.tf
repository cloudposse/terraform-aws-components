module "permission_sets" {
  source  = "cloudposse/sso/aws//modules/permission-sets"
  version = "0.6.2"

  permission_sets = concat(
    local.administrator_access_permission_set,
    local.billing_administrator_access_permission_set,
    local.billing_read_only_access_permission_set,
    local.dns_administrator_access_permission_set,
    local.identity_access_permission_sets,
    local.poweruser_access_permission_set,
    local.read_only_access_permission_set,
  )

  context = module.this.context
}

module "sso_account_assignments" {
  source  = "cloudposse/sso/aws//modules/account-assignments"
  version = "0.6.2"

  account_assignments = local.account_assignments
  context             = module.this.context
}

locals {
  enabled = module.this.enabled

  account_map = module.account_map.outputs.full_account_map
  account_assignments_groups = flatten([
    for account_key, account in var.account_assignments : [
      for principal_key, principal in account.groups : [
        for permissions_key, permissions in principal.permission_sets :
        {
          account             = local.account_map[account_key]
          permission_set_arn  = module.permission_sets.permission_sets[permissions].arn
          permission_set_name = module.permission_sets.permission_sets[permissions].name
          principal_name      = principal_key
          principal_type      = "GROUP"
        }
      ]
    ] if lookup(account, "groups", null) != null
  ])
  account_assignments_users = flatten([
    for account_key, account in var.account_assignments : [
      for principal_key, principal in account.users : [
        for permissions_key, permissions in principal.permission_sets :
        {
          account             = local.account_map[account_key]
          permission_set_arn  = module.permission_sets.permission_sets[permissions].arn
          permission_set_name = module.permission_sets.permission_sets[permissions].name
          principal_name      = principal_key
          principal_type      = "USER"
        }
      ]
    ] if lookup(account, "users", null) != null
  ])
  account_assignments = concat(local.account_assignments_groups, local.account_assignments_users)

  aws_partition = data.aws_partition.current.partition
}

data "aws_partition" "current" {}
