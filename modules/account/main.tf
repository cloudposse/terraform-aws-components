locals {
  organizational_units = toset(lookup(var.organizational_units_accounts_config, "organizational_units", []))

  organization_accounts         = toset(lookup(var.organizational_units_accounts_config, "accounts", []))
  organizational_units_accounts = toset(local.organizational_units[*]["accounts"])
  all_accounts                  = concat(local.organization_accounts, local.organizational_units_accounts)

  all_account_names = concat(
    values(aws_organizations_account.organization_accounts)[*]["name"],
    values(aws_organizations_account.organizational_units_accounts)[*]["name"]
  )

  all_account_arns = concat(
    values(aws_organizations_account.organization_accounts)[*]["arn"],
    values(aws_organizations_account.organizational_units_accounts)[*]["arn"]
  )

  all_account_ids = concat(
    values(aws_organizations_account.organization_accounts)[*]["id"],
    values(aws_organizations_account.organizational_units_accounts)[*]["id"]
  )

  organizational_unit_names = values(aws_organizations_organizational_unit.default)[*]["name"]
  organizational_unit_arns  = values(aws_organizations_organizational_unit.default)[*]["arn"]
  organizational_unit_ids   = values(aws_organizations_organizational_unit.default)[*]["id"]

  account_names_account_arns = zipmap(local.all_account_names, local.all_account_arns)
  account_names_account_ids  = zipmap(local.all_account_names, local.all_account_ids)

  organizational_unit_names_organizational_unit_arns = zipmap(local.organizational_unit_names, local.organizational_unit_arns)
  organizational_unit_names_organizational_unit_ids  = zipmap(local.organizational_unit_names, local.organizational_unit_ids)

  account_names_organizational_unit_names_map = length(local.organizational_units) > 0 ? merge(
    [
      for organizational_unit in local.organizational_units : {
        for account in lookup(organizational_unit, "accounts", []) : account.name => organizational_unit.name
      }
  ]...) : {}

  eks_account_names = [
    for acc in local.all_accounts : acc.name if acc.tags != null && lookup(acc.tags, "eks", false) == true
  ]

  non_eks_account_names = concat(
    [var.root_account_stage_name],
    setsubtract(local.all_account_names, local.eks_account_names)
  )

  service_control_policy_statements = flatten(
    [
      for file in fileset(path.module, "service-control-policies/*.yaml") : [
        for k, v in yamldecode(file(format("%s/%s", path.module, file))) : v
      ]
    ]
  )
}

resource "aws_organizations_organization" "default" {
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = "ALL"
}

resource "aws_organizations_account" "organization_accounts" {
  for_each                   = local.organization_accounts
  name                       = each.value.name
  email                      = format(var.account_email_format, each.value.name)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = merge(module.this.tags, each.value.tags)
}

resource "aws_organizations_organizational_unit" "default" {
  for_each  = local.organizational_units
  name      = each.value.name
  parent_id = aws_organizations_organization.default.roots[0].id
}

resource "aws_organizations_account" "organizational_units_accounts" {
  for_each                   = local.organizational_units_accounts
  name                       = each.value.name
  parent_id                  = aws_organizations_organizational_unit.default[local.account_names_organizational_unit_names_map[each.value.name]].id
  email                      = format(var.account_email_format, each.value.name)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = merge(module.this.tags, each.value.tags)
}

module "service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.1.0"

  service_control_policy_statements  = local.service_control_policy_statements
  service_control_policy_description = ""
  target_id                          = ""

  context = module.this.context
}


# organizational_units_accounts_config:
#   accounts:
#     - name: prod
#       tags:
#         eks: true
#       service_control_policies:
#         - DenyRootAccountAccess
#         - DenyLeavingOrganization
#         - DenyCreatingIAMUsers
#         - DenyDeletingKMSKeys
#         - DenyDeletingRoute53Zones
#     - name: staging
#       tags:
#         eks: true
#       service_control_policies:
#         - DenyRootAccountAccess
#         - DenyLeavingOrganization
#         - DenyCreatingIAMUsers
#         - DenyDeletingKMSKeys
#         - DenyDeletingRoute53Zones
#   organizational_units:
#   - name: security_audit
#     accounts:
#       - name: audit
#         service_control_policies:
#          - DenyRootAccountAccess
#       - name: security
#     service_control_policies:
#       - DenyLeavingOrganization
#       - DenyCreatingIAMUsers
#       - DenyDeletingKMSKeys
#       - DenyDeletingRoute53Zones

