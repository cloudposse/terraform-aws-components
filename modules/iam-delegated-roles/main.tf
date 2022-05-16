locals {
  roles_config      = { for key, value in var.roles : key => value if lookup(value, "enabled", false) }
  roles_policy_arns = { for role, config in local.roles_config : role => config.role_policy_arns }

  # It would be nice if we could use null-label and set name = each.key but we do not want the name to be normalized
  role_name_map = { for role_name, config in local.roles_config : role_name => format("%s%s%s", module.this.id, module.this.delimiter, role_name) }

  # If you want to create custom policies to add to multiple roles by name, create the policy
  # using an aws_iam_policy resource and then map it to the name you want to use in the
  # YAML configuration by adding an entry in `custom_policy_map`. See iam-primary-roles for an example.
  custom_policy_map = {
    support = aws_iam_policy.support.arn
  }

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

  saml_login_enabled = module.this.enabled && length(local.saml_provider_arns) > 0 ? contains([for v in local.roles_config : (v.enabled && v.sso_login_enabled)], true) : false
  saml_provider_arns = try(module.sso.outputs.saml_provider_arns, [])

  this_account_name = try(module.this.account, module.this.descriptors["account_name"], module.this.stage)


}

module "assume_role" {
  for_each = local.roles_config
  source   = "./modules/iam-assume-role-policy"

  allowed_roles           = { (var.iam_primary_roles_account_name) = each.value.trusted_primary_roles }
  denied_roles            = { (var.iam_primary_roles_account_name) = each.value.denied_primary_roles }
  allowed_principal_arns  = each.value.trusted_role_arns
  denied_principal_arns   = each.value.denied_role_arns
  allowed_permission_sets = { (local.this_account_name) = each.value.trusted_permission_sets }
  denied_permission_sets  = { (local.this_account_name) = each.value.denied_permission_sets }

  privileged = true

  context = module.this.context
}

data "aws_iam_policy_document" "saml_provider_assume" {
  count = local.saml_login_enabled ? 1 : 0

  statement {
    sid = "SamlProviderAssume"
    actions = [
      "sts:AssumeRoleWithSAML",
      "sts:TagSession",
    ]

    principals {
      type = "Federated"

      # Loop over the IDPs from the `sso` component
      identifiers = [for name, arn in local.saml_provider_arns : arn]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_aggregated" {
  for_each = local.roles_config

  source_policy_documents = concat([module.assume_role[each.key].policy_document],
  local.saml_login_enabled && local.roles_config[each.key].sso_login_enabled ? [data.aws_iam_policy_document.saml_provider_assume[0].json] : [])
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
