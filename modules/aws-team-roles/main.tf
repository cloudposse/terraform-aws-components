locals {
  roles_config      = { for key, value in var.roles : key => value if lookup(value, "enabled", false) }
  roles_policy_arns = { for role, config in local.roles_config : role => config.role_policy_arns }

  # It would be nice if we could use null-label and set name = each.key but we do not want the name to be normalized
  role_name_map = { for role_name, config in local.roles_config : role_name => format("%s%s%s", module.this.id, module.this.delimiter, role_name) }

  role_name_role_arn_map = { for key, value in local.roles_config : key => try(aws_iam_role.default[key].arn, null) }

  # If you want to create custom policies to add to multiple roles by name, create the policy
  # using an aws_iam_policy resource and then map it to the name you want to use in the
  # YAML configuration by adding an entry in `custom_policy_map`.
  supplied_custom_policy_map = {
    billing_read_only = try(aws_iam_policy.billing_read_only[0].arn, null)
    billing_admin     = try(aws_iam_policy.billing_admin[0].arn, null)
    support           = try(aws_iam_policy.support[0].arn, null)
    eks_viewer        = try(aws_iam_policy.eks_viewer[0].arn, null)
  }
  custom_policy_map = merge(local.supplied_custom_policy_map, local.overridable_additional_custom_policy_map)

  configured_policies = flatten([for k, v in local.roles_config : v.role_policy_arns])

  # Intermediate step in calculating all policy attachments.
  # Create a list of [role, arn] lists
  # role_attachments_product_list = concat([ for role_name, config in var.roles_config : setproduct([role_name], [for arn in config.role_policy_arns : arn]) ]...)
  # Also work around https://github.com/hashicorp/terraform/issues/22404
  # Create a list of strings that combine role name with policy ARN to attach to the role
  role_attachments_product_list = flatten([for role_name, arns in local.roles_policy_arns : [for arn in arns : "${role_name}+${arn}"]])
  role_attachments = { for role_arns in local.role_attachments_product_list : (
    # Make the first key just the role name, to keep the keys short when possible
    local.roles_policy_arns[split("+", role_arns)[0]][0] == split("+", role_arns)[1] ? split("+", role_arns)[0] : role_arns) =>
    # The value is the policy ARN to attach to the role
    try(local.custom_policy_map[split("+", role_arns)[1]], split("+", role_arns)[1])
  }

  this_account_name             = try(module.this.account, module.this.descriptors["account_name"], module.this.stage)
  identity_account_account_name = module.iam_roles.identity_account_account_name

  aws_partition = module.iam_roles.aws_partition
}

module "assume_role" {
  for_each = local.roles_config
  source   = "../account-map/modules/team-assume-role-policy"

  allowed_roles           = { (local.identity_account_account_name) = each.value.trusted_teams }
  denied_roles            = { (local.identity_account_account_name) = each.value.denied_teams }
  allowed_principal_arns  = each.value.trusted_role_arns
  denied_principal_arns   = each.value.denied_role_arns
  allowed_permission_sets = { (local.this_account_name) = each.value.trusted_permission_sets }
  denied_permission_sets  = { (local.this_account_name) = each.value.denied_permission_sets }

  trusted_github_repos = try(var.trusted_github_repos[each.key], [])

  privileged = true

  context = module.this.context
}

data "aws_iam_policy_document" "assume_role_aggregated" {
  for_each = local.roles_config

  source_policy_documents = compact(concat([module.assume_role[each.key].policy_document,
    module.assume_role[each.key].github_assume_role_policy],
  local.roles_config[each.key].aws_saml_login_enabled ? [module.aws_saml.outputs.saml_provider_assume_role_policy] : []))
}

resource "aws_iam_role" "default" {
  for_each = local.roles_config

  name                 = local.role_name_map[each.key]
  description          = each.value["role_description"]
  assume_role_policy   = data.aws_iam_policy_document.assume_role_aggregated[each.key].json
  max_session_duration = each.value["max_session_duration"]
  tags                 = merge(module.this.tags, { Name = local.role_name_map[each.key] })
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each = local.role_attachments

  role       = aws_iam_role.default[split("+", each.key)[0]].name
  policy_arn = each.value
}
