locals {
  enabled          = module.this.enabled
  managed_policies = [for arn in var.iam_policies : arn if can(regex("^arn:aws[^:]*:iam::aws:policy/", arn))]
  policies         = length(local.managed_policies) > 0 ? local.managed_policies : null
  policy_document_map = {
    "gitops"        = local.gitops_policy
    "lambda_cicd"   = local.lambda_cicd_policy
    "inline_policy" = one(module.iam_policy.*.json)
  }
  custom_policy_map = merge(local.policy_document_map, local.overridable_additional_custom_policy_map)

  # Ignore empty policies of the form `"{}"` as well as null policies
  active_policy_map = { for k, v in local.custom_policy_map : k => v if try(length(v), 0) > 3 }
}

module "iam_policy" {
  enabled = local.enabled && length(var.iam_policy) > 0

  source  = "cloudposse/iam-policy/aws"
  version = "2.0.1"

  iam_policy = var.iam_policy

  context = module.this.context
}

module "gha_assume_role" {
  source = "../account-map/modules/team-assume-role-policy"

  trusted_github_repos = var.github_actions_allowed_repos

  context = module.this.context
}

resource "aws_iam_role" "github_actions" {
  count = local.enabled ? 1 : 0

  name               = module.this.id
  assume_role_policy = module.gha_assume_role.github_assume_role_policy

  managed_policy_arns = local.policies

  dynamic "inline_policy" {
    for_each = local.active_policy_map
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }
}
