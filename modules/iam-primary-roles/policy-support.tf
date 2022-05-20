# This Terraform configuration file which creates a customer-managed policy exists in both iam-primary-roles and iam-delegated-roles.
#
# The reason for this is as follows:
#
# The support role (unlike most roles in the identity account) needs specific access to
# resources in the identity account. Policies must be created per-account, so the identity
# account needs a support policy, and that has to be created in iam-primary-roles.
#
# Other custom roles are only needed in either the identity or the other accounts, not both.
#

locals {
  support_policy_enabled = local.enabled_policies["support"]
}

data "aws_iam_policy_document" "support_access_trusted_advisor" {
  count = local.support_policy_enabled ? 1 : 0

  statement {
    sid    = "AllowTrustedAdvisor"
    effect = "Allow"
    actions = [
      "trustedadvisor:Describe*",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy" "aws_support_access" {
  count = local.support_policy_enabled ? 1 : 0

  arn = "arn:${local.aws_partition}:iam::aws:policy/AWSSupportAccess"
}

data "aws_iam_policy_document" "support_access_aggregated" {
  count = local.support_policy_enabled ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy.aws_support_access[0].policy,
    data.aws_iam_policy_document.support_access_trusted_advisor[0].json
  ]
}

resource "aws_iam_policy" "support" {
  count = local.support_policy_enabled ? 1 : 0

  name   = format("%s-support", module.this.id)
  policy = data.aws_iam_policy_document.support_access_aggregated[0].json

  tags = module.this.tags
}
