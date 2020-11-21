locals {
  # Organization config map
  organization = lookup(var.organization_config, "organization", {})

  # Organizational Units list and map configuration
  organizational_units     = lookup(var.organization_config, "organizational_units", [])
  organizational_units_map = { for ou in local.organizational_units : ou.name => ou }

  # Organization's Accounts list and map configuration
  organization_accounts     = lookup(var.organization_config, "accounts", [])
  organization_accounts_map = { for acc in local.organization_accounts : acc.name => acc }

  # Organizational Units' Accounts list and map configuration
  organizational_units_accounts     = flatten([for ou in local.organizational_units : lookup(ou, "accounts", [])])
  organizational_units_accounts_map = { for acc in local.organizational_units_accounts : acc.name => acc }

  # All Accounts configuration
  all_accounts = concat(local.organization_accounts, local.organizational_units_accounts)

  # List of Organizational Unit names
  organizational_unit_names = values(aws_organizations_organizational_unit.this)[*]["name"]

  # List of Organizational Unit ARNs
  organizational_unit_arns = values(aws_organizations_organizational_unit.this)[*]["arn"]

  # List of Organizational Unit IDs
  organizational_unit_ids = values(aws_organizations_organizational_unit.this)[*]["id"]

  # Map of account names to OU names (used for lookup `parent_id` for each account under an OU)
  account_names_organizational_unit_names_map = length(local.organizational_units) > 0 ? merge(
    [
      for organizational_unit in local.organizational_units : {
        for account in lookup(organizational_unit, "accounts", []) : account.name => organizational_unit.name
      }
  ]...) : {}

  # Convert all Service Control Policy statements from YAML config to Terraform list
  all_service_control_policy_statements = module.service_control_policy_statements_yaml_config.list_configs

  # Service Control Policy SIDs for Organization
  organization_service_control_policy_ids = lookup(local.organization, "service_control_policies", [])

  # List of Service Control Policy statements for Organization
  organization_service_control_policy_statements = [
    for st in local.all_service_control_policy_statements : st if contains(local.organization_service_control_policy_ids, st.sid)
  ]

  # Map of account names to list Service Control Policy SIDs for each account
  account_names_service_control_policy_ids_map = {
    for acc in local.all_accounts : acc.name => acc.service_control_policies if try(acc.service_control_policies, null) != null
  }

  # Map of account names to list of Service Control Policy statements for each account
  account_names_service_control_policy_statements_map = {
    for k, v in local.account_names_service_control_policy_ids_map : k => [
      for st in local.all_service_control_policy_statements : st if contains(v, st.sid)
    ]
  }

  # Map of OU names to list of Service Control Policy SIDs for each OU
  organizational_unit_names_service_control_policy_ids_map = length(local.organizational_units) > 0 ? {
    for ou in local.organizational_units : ou.name => ou.service_control_policies if try(ou.service_control_policies, null) != null
  } : {}

  # Map of OU names to list of Service Control Policy statements for each OU
  organizational_unit_names_service_control_policy_statements_map = {
    for k, v in local.organizational_unit_names_service_control_policy_ids_map : k => [
      for st in local.all_service_control_policy_statements : st if contains(v, st.sid)
    ]
  }
}

# Convert all Service Control Policy statements from YAML config to Terraform list
module "service_control_policy_statements_yaml_config" {
  source = "git::https://github.com/cloudposse/terraform-yaml-config.git?ref=tags/0.1.0"

  list_config_local_base_path = path.module
  list_config_paths           = var.service_control_policies_config_paths

  context = module.this.context
}

# Provision Organization or use existing one
data "aws_organizations_organization" "existing" {
  count = var.organization_enabled ? 0 : 1
}

resource "aws_organizations_organization" "this" {
  count                         = var.organization_enabled ? 1 : 0
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = "ALL"
}

locals {
  organization_root_account_id = var.organization_enabled ? aws_organizations_organization.this[0].roots[0].id : data.aws_organizations_organization.existing[0].roots[0].id

  organization_id = var.organization_enabled ? aws_organizations_organization.this[0].id : data.aws_organizations_organization.existing[0].id

  organization_arn = var.organization_enabled ? aws_organizations_organization.this[0].arn : data.aws_organizations_organization.existing[0].arn

  organization_master_account_id = var.organization_enabled ? aws_organizations_organization.this[0].master_account_id : data.aws_organizations_organization.existing[0].master_account_id

  organization_master_account_arn = var.organization_enabled ? aws_organizations_organization.this[0].master_account_arn : data.aws_organizations_organization.existing[0].master_account_arn

  organization_master_account_email = var.organization_enabled ? aws_organizations_organization.this[0].master_account_email : data.aws_organizations_organization.existing[0].master_account_email
}

# Provision Accounts for Organization (not connected to OUs)
resource "aws_organizations_account" "organization_accounts" {
  for_each                   = local.organization_accounts_map
  name                       = each.value.name
  email                      = format(var.account_email_format, each.value.name)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = merge(module.this.tags, try(each.value.tags, {}), { Name : each.value.name })
}

# Provision Organizational Units
resource "aws_organizations_organizational_unit" "this" {
  for_each  = local.organizational_units_map
  name      = each.value.name
  parent_id = local.organization_root_account_id
}

# Provision Accounts connected to Organizational Units
resource "aws_organizations_account" "organizational_units_accounts" {
  for_each                   = local.organizational_units_accounts_map
  name                       = each.value.name
  parent_id                  = aws_organizations_organizational_unit.this[local.account_names_organizational_unit_names_map[each.value.name]].id
  email                      = format(var.account_email_format, each.value.name)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = merge(module.this.tags, try(each.value.tags, {}), { Name : each.value.name })
}

# Provision Organization Service Control Policy
module "organization_service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.4.0"

  count = length(local.organization_service_control_policy_statements) > 0 ? 1 : 0

  attributes                         = concat(module.this.attributes, ["organization"])
  service_control_policy_statements  = local.organization_service_control_policy_statements
  service_control_policy_description = "Organization Service Control Policy"
  target_id                          = local.organization_root_account_id

  context = module.this.context
}

# Provision Accounts Service Control Policies
module "accounts_service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.4.0"

  for_each = local.account_names_service_control_policy_statements_map

  attributes                         = concat(module.this.attributes, [each.key, "account"])
  service_control_policy_statements  = each.value
  service_control_policy_description = "'${each.key}' Account Service Control Policy"
  target_id                          = local.account_names_account_ids[each.key]

  context = module.this.context
}

# Provision Organizational Units Service Control Policies
module "organizational_units_service_control_policies" {
  source = "git::https://github.com/cloudposse/terraform-aws-service-control-policies.git?ref=tags/0.4.0"

  for_each = local.organizational_unit_names_service_control_policy_statements_map

  attributes                         = concat(module.this.attributes, [each.key, "ou"])
  service_control_policy_statements  = each.value
  service_control_policy_description = "'${each.key}' Organizational Unit Service Control Policy"
  target_id                          = local.organizational_unit_names_organizational_unit_ids[each.key]

  context = module.this.context
}


# Locals for outputs
locals {
  # List of names of all accounts (belonging to Organization and Organizational Units)
  all_account_names = concat(
    values(aws_organizations_account.organization_accounts)[*]["name"],
    values(aws_organizations_account.organizational_units_accounts)[*]["name"]
  )

  # List of ARNs of all accounts (belonging to Organization and Organizational Units)
  all_account_arns = concat(
    values(aws_organizations_account.organization_accounts)[*]["arn"],
    values(aws_organizations_account.organizational_units_accounts)[*]["arn"]
  )

  # List of IDs of all accounts (belonging to Organization and Organizational Units)
  all_account_ids = concat(
    values(aws_organizations_account.organization_accounts)[*]["id"],
    values(aws_organizations_account.organizational_units_accounts)[*]["id"]
  )

  # Map of account names to account ARNs
  account_names_account_arns = zipmap(local.all_account_names, local.all_account_arns)

  # Map of account names to account IDs
  account_names_account_ids = zipmap(local.all_account_names, local.all_account_ids)

  # Map of OU names to OU ARNs
  organizational_unit_names_organizational_unit_arns = zipmap(local.organizational_unit_names, local.organizational_unit_arns)

  # Map of OU names to OU IDs
  organizational_unit_names_organizational_unit_ids = zipmap(local.organizational_unit_names, local.organizational_unit_ids)

  # Names of the accounts with EKS cluster
  eks_account_names = [
    for acc in local.all_accounts : acc.name if lookup(try(acc.tags, {}), "eks", false) == true
  ]

  # Names of the non-EKS accounts
  non_eks_account_names = concat(
    [var.root_account_stage_name],
    [for acc in local.all_accounts : acc.name if lookup(try(acc.tags, {}), "eks", false) == false]
  )

  # Map of account names to SCP IDs
  account_names_account_scp_ids = {
    for k, v in local.account_names_service_control_policy_statements_map : k => module.accounts_service_control_policies[k].organizations_policy_id
  }

  # Map of account names to SCP ARNs
  account_names_account_scp_arns = {
    for k, v in local.account_names_service_control_policy_statements_map : k => module.accounts_service_control_policies[k].organizations_policy_arn
  }

  # Map of OU names to SCP IDs
  organizational_unit_names_organizational_unit_scp_ids = {
    for k, v in local.organizational_unit_names_service_control_policy_statements_map : k => module.organizational_units_service_control_policies[k].organizations_policy_id
  }

  # Map of OU names to SCP ARNs
  organizational_unit_names_organizational_unit_scp_arns = {
    for k, v in local.organizational_unit_names_service_control_policy_statements_map : k => module.organizational_units_service_control_policies[k].organizations_policy_arn
  }
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
#   - name: security-audit
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
