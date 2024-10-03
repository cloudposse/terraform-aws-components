locals {
  enabled     = module.this.enabled
  account_map = module.account_map.outputs.full_account_map

  current_account_id                     = one(data.aws_caller_identity.this[*].account_id)
  member_account_id_list                 = [for a in keys(local.account_map) : (local.account_map[a]) if contains(var.member_accounts, a) && local.account_map[a] != local.org_delegated_administrator_account_id]
  org_delegated_administrator_account_id = local.account_map[var.delegated_administrator_account_name]
  org_management_account_id              = var.organization_management_account_name == null ? local.account_map[module.account_map.outputs.root_account_account_name] : local.account_map[var.organization_management_account_name]
  is_org_delegated_administrator_account = local.current_account_id == local.org_delegated_administrator_account_id
  is_org_management_account              = local.current_account_id == local.org_management_account_id

  is_root_account_member_account = local.is_org_management_account && contains(local.member_account_id_list, local.org_management_account_id)
  create_macie_account           = local.enabled && ((local.is_org_delegated_administrator_account && !var.admin_delegated) || local.is_root_account_member_account)
  create_org_delegation          = local.enabled && local.is_org_management_account
  create_org_settings            = local.enabled && local.is_org_delegated_administrator_account && var.admin_delegated
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

# If we are are in the AWS Org management account, delegate Macie to the org administrator account
# (usually the security account)
resource "aws_macie2_organization_admin_account" "this" {
  count            = local.create_org_delegation ? 1 : 0
  admin_account_id = local.org_delegated_administrator_account_id
}

resource "awsutils_macie2_organization_settings" "this" {
  count           = local.create_org_settings ? 1 : 0
  member_accounts = local.member_account_id_list
}

# If we are are in the AWS Org designated administrator account, enable macie detector and optionally create an
# SNS topic for notifications and CloudWatch event rules for findings
resource "aws_macie2_account" "this" {
  count = local.create_macie_account ? 1 : 0

  finding_publishing_frequency = var.finding_publishing_frequency
  status                       = "ENABLED"
}
