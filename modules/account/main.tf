locals {
  organization                  = lookup(var.organization_config, "organization", {})
  organizational_units          = toset(lookup(var.organization_config, "organizational_units", []))
  organization_accounts         = toset(lookup(var.organization_config, "accounts", []))
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

  account_names_organizational_unit_names_map = local.organizational_units != null && length(local.organizational_units) > 0 ? merge(
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

  all_service_control_policy_statements = flatten(
    [
      for file in fileset(path.module, "service-control-policies/*.yaml") : [
        for k, v in yamldecode(file(format("%s/%s", path.module, file))) : v
      ]
    ]
  )

  organization_service_control_policy_ids = lookup(local.organization, "service_control_policies", [])

  organization_service_control_policy_statements = [
    for st in local.all_service_control_policy_statements : st if contains(local.organization_service_control_policy_ids, st.sid)
  ]

  account_names_service_control_policy_ids_map = {
    for acc in local.all_accounts : acc.name => acc.service_control_policies if acc.service_control_policies != null && length(acc.service_control_policies) > 0
  }

  account_names_service_control_policy_statements_map = {
    for k, v in local.account_names_service_control_policy_ids_map : k => [
      for st in local.all_service_control_policy_statements : st if contains(v, st.sid)
    ]
  }

  organizational_unit_names_service_control_policy_ids_map = local.organizational_units != null && length(local.organizational_units) > 0 ? {
    for ou in local.organizational_units : ou.name => ou.service_control_policies if ou.service_control_policies != null && length(ou.service_control_policies) > 0
  } : {}

  organizational_unit_names_service_control_policy_statements_map = {
    for k, v in local.organizational_unit_names_service_control_policy_ids_map : k => [
      for st in local.all_service_control_policy_statements : st if contains(v, st.sid)
    ]
  }
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

module "organization_service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.1.0"

  for_each = length(local.organization_service_control_policy_statements) > 0 ? [true] : []

  attributes                         = concat(module.this.attributes, ["organization"])
  service_control_policy_statements  = local.organization_service_control_policy_statements
  service_control_policy_description = "Organization Service Control Policy"
  target_id                          = aws_organizations_organization.default.roots[0].id

  context = module.this.context
}

module "accounts_service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.3.0"

  for_each = local.account_names_service_control_policy_statements_map

  attributes                         = concat(module.this.attributes, [each.key, "account"])
  service_control_policy_statements  = each.value
  service_control_policy_description = "${each.key} Account Service Control Policy"
  target_id                          = local.account_names_account_ids[each.key]

  context = module.this.context
}

module "organizational_units_service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.3.0"

  for_each = local.organizational_unit_names_service_control_policy_statements_map

  attributes                         = concat(module.this.attributes, [each.key, "ou"])
  service_control_policy_statements  = each.value
  service_control_policy_description = "${titlecase(each.key)} Organizational Unit Service Control Policy"
  target_id                          = local.organizational_unit_names_organizational_unit_ids[each.key]

  context = module.this.context
}


# organization_config:
#   organization:
#     service_control_policies:
#       - DenyS3BucketsPublicAccess
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
#         - DenyDeletingCloudWatchLogs
#     - name: staging
#       tags:
#         eks: true
#       service_control_policies:
#         - DenyRootAccountAccess
#         - DenyLeavingOrganization
#         - DenyCreatingIAMUsers
#         - DenyDeletingKMSKeys
#         - DenyDeletingRoute53Zones
#         - DenyDeletingCloudWatchLogs
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
#       - ProtectS3Buckets
#       - DenyS3BucketsPublicAccess
#       - DenyS3IncorrectEncryptionHeader
#       - DenyS3UnEncryptedObjectUploads
