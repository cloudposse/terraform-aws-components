locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map

  current_account_id = one(data.aws_caller_identity.this[*].account_id)
  member_account_ids = [for a in keys(local.account_map) : (local.account_map[a]) if(local.account_map[a] != local.current_account_id) && !contains(var.member_association_excludes, local.account_map[a])]

  org_delegated_administrator_account_id = local.account_map[var.delegated_administrator_account_name]
  org_management_account_id              = var.organization_management_account_name == null ? local.account_map[module.account_map.outputs.root_account_account_name] : local.account_map[var.organization_management_account_name]

  is_org_delegated_administrator_account = local.current_account_id == local.org_delegated_administrator_account_id
  is_org_management_account              = local.current_account_id == local.org_management_account_id

  create_org_delegation    = local.enabled && local.is_org_management_account
  create_org_configuration = local.enabled && local.is_org_delegated_administrator_account && var.admin_delegated

  resource_types = compact([var.auto_enable_ec2 ? "EC2" : null, var.auto_enable_ecr ? "ECR" : null, var.auto_enable_lambda ? "Lambda" : null])
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

# If we are in the AWS Organization management account, delegate Inspector2 to
# the administrator account (usually the security account).
resource "aws_inspector2_delegated_admin_account" "default" {
  count      = local.create_org_delegation ? 1 : 0
  account_id = local.org_delegated_administrator_account_id
}

resource "aws_inspector2_enabler" "delegated_admin" {
  count = local.create_org_configuration ? 1 : 0

  account_ids    = [local.org_delegated_administrator_account_id]
  resource_types = local.resource_types
}

# If we are are in the AWS Organization designated administrator account,
# configure all other accounts to send their Inspector2 findings.
resource "aws_inspector2_organization_configuration" "default" {
  count = local.create_org_configuration ? 1 : 0

  depends_on = [aws_inspector2_enabler.delegated_admin]
  auto_enable {
    ec2    = var.auto_enable_ec2
    ecr    = var.auto_enable_ecr
    lambda = var.auto_enable_lambda
  }
}

resource "aws_inspector2_enabler" "member_accounts" {
  count = local.create_org_configuration ? 1 : 0

  depends_on = [aws_inspector2_member_association.default]

  account_ids    = local.member_account_ids
  resource_types = local.resource_types
}

resource "aws_inspector2_member_association" "default" {
  for_each   = local.create_org_configuration ? toset(local.member_account_ids) : []
  account_id = each.value
}
