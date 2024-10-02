locals {
  # Organization config map
  organization = lookup(var.organization_config, "organization", {})

  # Organizational Units list and map configuration
  organizational_units = lookup(var.organization_config, "organizational_units", [])
  organizational_units_map = { for ou in local.organizational_units : ou.name => merge(ou, {
    parent_ou = contains(keys(ou), "parent_ou") ? ou.parent_ou : "none"
  }) }

  # Organization's Accounts list and map configuration
  organization_accounts     = lookup(var.organization_config, "accounts", [])
  organization_accounts_map = { for acc in local.organization_accounts : acc.name => acc }

  # Organizational Units' Accounts list and map configuration
  organizational_units_accounts = flatten([
    for ou in local.organizational_units : [
      for account in lookup(ou, "accounts", []) : merge({ "ou" = ou.name, "account_email_format" = lookup(ou, "account_email_format", var.account_email_format), parent_ou = contains(keys(ou), "parent_ou") ? ou.parent_ou : "none" }, account)
    ]
  ])
  organizational_units_accounts_map = { for acc in local.organizational_units_accounts : acc.name => acc }

  # All Accounts configuration
  all_accounts = concat(local.organization_accounts, local.organizational_units_accounts)

  # List of Organizational Unit names
  organizational_unit_names = concat(
    values(aws_organizations_organizational_unit.this)[*]["name"],
    values(aws_organizations_organizational_unit.child)[*]["name"]
  )

  # List of Organizational Unit ARNs
  organizational_unit_arns = concat(
    values(aws_organizations_organizational_unit.this)[*]["arn"],
    values(aws_organizations_organizational_unit.child)[*]["arn"]
  )

  # List of Organizational Unit IDs
  organizational_unit_ids = concat(
    values(aws_organizations_organizational_unit.this)[*]["id"],
    values(aws_organizations_organizational_unit.child)[*]["id"]
  )

  # Map of account names to OU names (used for lookup `parent_id` for each account under an OU)
  account_names_organizational_unit_names_map = length(local.organizational_units) > 0 ? merge(
    [
      for organizational_unit in local.organizational_units : {
        for account in lookup(organizational_unit, "accounts", []) : account.name => organizational_unit.name
      }
  ]...) : {}

  # Convert all Service Control Policy statements from YAML config to Terraform list
  all_service_control_policy_statements = module.service_control_policy_statements_yaml_config.list_configs

  # Convert to map, so we can lookup by name and detect missing policies
  all_service_control_policy_statements_map = { for st in local.all_service_control_policy_statements : st.sid => st }

  # Service Control Policy SIDs for Organization
  organization_service_control_policy_ids = lookup(local.organization, "service_control_policies", [])

  # List of Service Control Policy statements for Organization
  organization_service_control_policy_statements = [
    for sid in local.organization_service_control_policy_ids : local.all_service_control_policy_statements_map[sid]
  ]

  # Map of account names to list Service Control Policy SIDs for each account
  account_names_service_control_policy_ids_map = {
    for acc in local.all_accounts : acc.name => acc.service_control_policies if try(acc.service_control_policies, null) != null
  }

  # Map of account names to list of Service Control Policy statements for each account
  account_names_service_control_policy_statements_map = {
    for k, v in local.account_names_service_control_policy_ids_map : k => [
      for sid in v : local.all_service_control_policy_statements_map[sid]
    ]
  }

  # Map of OU names to list of Service Control Policy SIDs for each OU
  organizational_unit_names_service_control_policy_ids_map = length(local.organizational_units) > 0 ? {
    for ou in local.organizational_units : ou.name => ou.service_control_policies if try(ou.service_control_policies, null) != null
  } : {}

  # Map of OU names to list of Service Control Policy statements for each OU
  organizational_unit_names_service_control_policy_statements_map = {
    for k, v in local.organizational_unit_names_service_control_policy_ids_map : k => [
      for sid in v : local.all_service_control_policy_statements_map[sid]
    ]
  }
}

# Convert all Service Control Policy statements from YAML config to Terraform list
module "service_control_policy_statements_yaml_config" {
  source  = "cloudposse/config/yaml"
  version = "1.0.2"

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
  email                      = format(each.value.account_email_format, each.value.name)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = merge(module.this.tags, try(each.value.tags, {}), { Name : each.value.name })

  lifecycle {
    ignore_changes = [iam_user_access_to_billing]
  }
}

# Provision Organizational Units w/o Child Orgs
resource "aws_organizations_organizational_unit" "this" {
  for_each  = { for key, value in local.organizational_units_map : key => value if value.parent_ou == "none" }
  name      = each.value.name
  parent_id = local.organization_root_account_id
}

# Provision Child Organizational Units
resource "aws_organizations_organizational_unit" "child" {
  for_each  = { for key, value in local.organizational_units_map : key => value if value.parent_ou != "none" }
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.this[each.value.parent_ou].id
}

# Provision Accounts connected to Organizational Units
resource "aws_organizations_account" "organizational_units_accounts" {
  for_each                   = local.organizational_units_accounts_map
  name                       = each.value.name
  parent_id                  = each.value.parent_ou != "none" ? aws_organizations_organizational_unit.child[each.value.ou].id : aws_organizations_organizational_unit.this[local.account_names_organizational_unit_names_map[each.value.name]].id
  email                      = try(format(each.value.account_email_format, each.value.name), each.value.account_email_format)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = merge(module.this.tags, try(each.value.tags, {}), { Name : each.value.name })

  lifecycle {
    ignore_changes = [iam_user_access_to_billing]
  }
}

# Provision Organization Service Control Policy
module "organization_service_control_policies" {
  source  = "cloudposse/service-control-policies/aws"
  version = "0.9.2"

  count = length(local.organization_service_control_policy_statements) > 0 ? 1 : 0

  attributes                         = concat(module.this.attributes, ["organization"])
  service_control_policy_statements  = local.organization_service_control_policy_statements
  service_control_policy_description = "Organization Service Control Policy"
  target_id                          = local.organization_root_account_id

  context = module.this.context
}

# Provision Accounts Service Control Policies
module "accounts_service_control_policies" {
  source  = "cloudposse/service-control-policies/aws"
  version = "0.9.2"

  for_each = local.account_names_service_control_policy_statements_map

  attributes                         = concat(module.this.attributes, [each.key, "account"])
  service_control_policy_statements  = each.value
  service_control_policy_description = "'${each.key}' Account Service Control Policy"
  target_id                          = local.account_names_account_ids[each.key]

  context = module.this.context
}

# Provision Organizational Units Service Control Policies
module "organizational_units_service_control_policies" {
  source  = "cloudposse/service-control-policies/aws"
  version = "0.9.2"

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
    [lookup(var.organization_config.root_account, "name", "root")],
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

  account_info_map = merge({ for acc in local.all_accounts : acc.name => merge({ for k, v in acc : k => v if k != "name" },
    {
      eks    = tobool(lookup(try(acc.tags, {}), "eks", false))
      id     = local.account_names_account_ids[acc.name]
      tenant = try(acc.tenant, var.tenant)
      stage  = try(acc.stage, acc.name)
    }) },
    {
      (var.organization_config.root_account.name) = merge({ for k, v in var.organization_config.root_account : k => v if k != "name" }, {
        id     = local.organization_master_account_id
        eks    = tobool(lookup(try(var.organization_config.root_account.tags, {}), "eks", false))
        tenant = var.tenant
        stage  = try(var.organization_config.root_account.stage, var.organization_config.root_account.name)
      })
  })

}
