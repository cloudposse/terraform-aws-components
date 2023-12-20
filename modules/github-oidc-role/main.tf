locals {
  enabled             = module.this.enabled
  aws_canned_policies = [for arn in var.aws_iam_policies : arn if can(regex("^arn:aws:iam::aws:policy/", arn))]
  aws_policies        = length(local.aws_canned_policies) > 0 ? local.aws_canned_policies : null
  policy_document_map = {
    "gitops"        = local.gitops_policy
    "lambda_cicd"   = local.lambda_cicd_policy
    "inline_policy" = one(module.iam_policy.*.json)
  }
  active_policy_map = { for k, v in local.policy_document_map : k => v if v != null }
}

module "iam_policy" {
  enabled = local.enabled && length(var.iam_policy) > 0

  source  = "cloudposse/iam-policy/aws"
  version = "2.0.1"

  iam_policy = var.iam_policy
}

module "gha_role_name" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = compact(concat(var.github_actions_iam_role_attributes, ["gha"]))

  context = module.this.context
}

module "gha_assume_role" {
  source = "../account-map/modules/team-assume-role-policy"

  trusted_github_repos = var.github_actions_allowed_repos

  context = module.this.context
}

resource "aws_iam_role" "github_actions" {
  count = local.enabled ? 1 : 0

  name               = module.gha_role_name.id
  assume_role_policy = module.gha_assume_role.github_assume_role_policy

  managed_policy_arns = local.aws_policies

  dynamic "inline_policy" {
    for_each = local.active_policy_map
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }
}
