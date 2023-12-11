locals {
  enabled = module.this.enabled

  account_map  = module.account_map.outputs.full_account_map
  root_account = local.account_map[module.account_map.outputs.root_account_account_name]

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
  # Remove root because the identity org role cannot provision root assignments
  account_assignments_groups_no_root = [
    for val in local.account_assignments_groups :
    val
    if val.account != local.root_account
  ]
  account_assignments_groups_only_root = [
    for val in local.account_assignments_groups :
    val
    if val.account == local.root_account
  ]
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
  account_assignments_users_no_root = [
    for val in local.account_assignments_users :
    val
    if val.account != local.root_account
  ]
  account_assignments_users_only_root = [
    for val in local.account_assignments_users :
    val
    if val.account == local.root_account
  ]

  account_assignments      = concat(local.account_assignments_groups_no_root, local.account_assignments_users_no_root)
  account_assignments_root = concat(local.account_assignments_groups_only_root, local.account_assignments_users_only_root)

  aws_partition = data.aws_partition.current.partition
}

data "aws_ssoadmin_instances" "this" {}

data "aws_partition" "current" {}

resource "aws_identitystore_group" "manual" {
  for_each = toset(var.groups)

  display_name = each.key
  description  = "Group created with Terraform"

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

module "permission_sets" {
  source  = "cloudposse/sso/aws//modules/permission-sets"
  version = "1.1.1"

  permission_sets = concat(
    local.overridable_additional_permission_sets,
    local.administrator_access_permission_set,
    local.billing_administrator_access_permission_set,
    local.billing_read_only_access_permission_set,
    local.dns_administrator_access_permission_set,
    local.identity_access_permission_sets,
    local.poweruser_access_permission_set,
    local.read_only_access_permission_set,
    local.terraform_update_access_permission_set,
  )

  context = module.this.context

  depends_on = [
    aws_identitystore_group.manual
  ]
}

module "sso_account_assignments" {
  source  = "cloudposse/sso/aws//modules/account-assignments"
  version = "1.1.1"

  account_assignments = local.account_assignments
  context             = module.this.context

  depends_on = [
    aws_identitystore_group.manual
  ]
}

module "sso_account_assignments_root" {
  source  = "cloudposse/sso/aws//modules/account-assignments"
  version = "1.1.1"

  providers = {
    aws = aws.root
  }

  account_assignments = local.account_assignments_root
  context             = module.this.context

  depends_on = [
    aws_identitystore_group.manual
  ]
}
