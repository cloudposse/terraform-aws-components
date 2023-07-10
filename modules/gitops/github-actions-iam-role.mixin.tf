# This mixin requires that a local variable named `github_actions_iam_policy` be defined
# and its value to be a JSON IAM Policy Document defining the permissions for the role.
# It also requires that the `github-oidc-provider` has been previously installed and the
# `github-assume-role-policy.mixin.tf` has been added to `account-map/modules/team-assume-role-policy`.

variable "github_actions_iam_role_enabled" {
  type        = bool
  description = <<-EOF
  Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources
  EOF
  default     = false
}

variable "github_actions_allowed_repos" {
  type        = list(string)
  description = <<EOF
  A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,
  ["cloudposse/infra-live"]. Can contain "*" as wildcard.
  If org part of repo name is omitted, "cloudposse" will be assumed.
  EOF
  default     = []
}

variable "github_actions_iam_role_attributes" {
  type        = list(string)
  description = "Additional attributes to add to the role name"
  default     = []
}


locals {
  github_actions_iam_role_enabled = local.enabled && var.github_actions_iam_role_enabled && length(var.github_actions_allowed_repos) > 0
}

module "gha_role_name" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled    = local.github_actions_iam_role_enabled
  attributes = compact(concat(var.github_actions_iam_role_attributes, ["gha"]))

  context = module.this.context
}

module "gha_assume_role" {
  source = "../account-map/modules/team-assume-role-policy"

  trusted_github_repos = var.github_actions_allowed_repos

  context = module.gha_role_name.context
}

resource "aws_iam_role" "github_actions" {
  count              = local.github_actions_iam_role_enabled ? 1 : 0
  name               = module.gha_role_name.id
  assume_role_policy = module.gha_assume_role.github_assume_role_policy

  inline_policy {
    name   = module.gha_role_name.id
    policy = local.github_actions_iam_policy
  }
}

output "github_actions_iam_role_arn" {
  value       = one(aws_iam_role.github_actions[*].arn)
  description = "ARN of IAM role for GitHub Actions"
}

output "github_actions_iam_role_name" {
  value       = one(aws_iam_role.github_actions[*].name)
  description = "Name of IAM role for GitHub Actions"
}
