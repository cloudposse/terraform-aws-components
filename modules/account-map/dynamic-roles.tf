
data "utils_describe_stacks" "teams" {
  count = local.dynamic_role_enabled ? 1 : 0

  components      = ["aws-teams"]
  component_types = ["terraform"]
  sections        = ["vars"]
}

data "utils_describe_stacks" "team_roles" {
  count = local.dynamic_role_enabled ? 1 : 0

  components      = ["aws-team-roles"]
  component_types = ["terraform"]
  sections        = ["vars"]
}

locals {
  dynamic_role_enabled = module.this.enabled && var.terraform_dynamic_role_enabled

  apply_role = var.terraform_role_name_map.apply
  plan_role  = var.terraform_role_name_map.plan

  # zero-based index showing position of the namespace in the stack name
  stack_namespace_index = try(index(module.this.normalized_context.descriptor_formats.stack.labels, "namespace"), -1)
  stack_has_namespace   = local.stack_namespace_index >= 0
  stack_account_map     = { for k, v in module.atmos : k => lookup(v.descriptors, "account_name", v.stage) }

  # We would like to use code like this:
  #   teams_stacks = local.dynamic_role_enabled ? { for k, v ... } : {}
  # but that generates an error: "Inconsistent conditional result types"
  # See https://github.com/hashicorp/terraform/issues/33303
  # To work around this, we have "empty" values that depend on the condition.
  empty_map = {
    true  = null
    false = {}
  }
  empty = local.empty_map[local.dynamic_role_enabled]

  # ASSUMPTIONS: The stack pattern is the same for all accounts and uses the same delimiter as null-label
  teams_stacks = local.dynamic_role_enabled ? {
    for k, v in yamldecode(data.utils_describe_stacks.teams[0].output) : k => v if !local.stack_has_namespace || try(split(module.this.delimiter, k)[local.stack_namespace_index] == module.this.namespace, false)
  } : local.empty

  teams_vars   = { for k, v in local.teams_stacks : k => v.components.terraform.aws-teams.vars }
  teams_config = local.dynamic_role_enabled ? values(local.teams_vars)[0].teams_config : local.empty
  team_names   = [for k, v in local.teams_config : k if try(v.enabled, true)]
  team_arns    = { for team_name in local.team_names : team_name => format(local.iam_role_arn_templates[local.account_role_map.identity], team_name) }

  team_roles_stacks = local.dynamic_role_enabled ? {
    for k, v in yamldecode(data.utils_describe_stacks.team_roles[0].output) : k => v if !local.stack_has_namespace || try(split(module.this.delimiter, k)[local.stack_namespace_index] == module.this.namespace, false)
  } : local.empty

  team_roles_vars = { for k, v in local.team_roles_stacks : k => v.components.terraform.aws-team-roles.vars }

  stack_planners     = { for k, v in local.team_roles_vars : k => v.roles[local.plan_role].trusted_teams if try(length(v.roles[local.plan_role].trusted_teams), 0) > 0 && try(v.roles[local.plan_role].enabled, true) }
  stack_terraformers = { for k, v in local.team_roles_vars : k => v.roles[local.apply_role].trusted_teams if try(length(v.roles[local.apply_role].trusted_teams), 0) > 0 && try(v.roles[local.apply_role].enabled, true) }

  all_team_vars = merge(local.teams_vars, local.team_roles_vars)

  team_planners = { for team in local.team_names : team => {
    for stack, trusted in local.stack_planners : local.stack_account_map[stack] => "plan" if contains(trusted, team)
  } }
  team_terraformers = { for team in local.team_names : team => {
    for stack, trusted in local.stack_terraformers : local.stack_account_map[stack] => "apply" if contains(trusted, team)
  } }

  role_arn_terraform_access = { for team in local.team_names : local.team_arns[team] => merge(local.team_planners[team], local.team_terraformers[team]) }
}

module "atmos" {
  # local.all_team_vars is empty map when dynamic_role_enabled is false
  for_each = local.all_team_vars

  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled             = true
  namespace           = lookup(each.value, "namespace", null)
  tenant              = lookup(each.value, "tenant", null)
  environment         = lookup(each.value, "environment", null)
  stage               = lookup(each.value, "stage", null)
  name                = lookup(each.value, "name", null)
  delimiter           = lookup(each.value, "delimiter", null)
  attributes          = lookup(each.value, "attributes", [])
  tags                = lookup(each.value, "tags", {})
  additional_tag_map  = lookup(each.value, "additional_tag_map", {})
  label_order         = lookup(each.value, "label_order", [])
  regex_replace_chars = lookup(each.value, "regex_replace_chars", null)
  id_length_limit     = lookup(each.value, "id_length_limit", null)
  label_key_case      = lookup(each.value, "label_key_case", null)
  label_value_case    = lookup(each.value, "label_value_case", null)
  descriptor_formats  = lookup(each.value, "descriptor_formats", {})
  labels_as_tags      = lookup(each.value, "labels_as_tags", [])
}
