# This Terraform configuration file which creates a customer-managed policy exists in both iam-primary-roles and iam-delegated-roles.
#
# The reason for this is as follows:
#
# When iam-primary-roles creates this policy and allows it to be referenced by its short name in its configuration,
# it also exports its configuration such that it can be consumed by iam-delegated-roles.
# The latter component will then attempt to attach this customer-managed policy as per the exported configuration.
#
# Because of this, the iam-delegated-roles component needs to both create this same policy in the target account and map the short name to it
# in order to be able to attach it to the appropriate roles, as per the exported configuration.

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

  tags = module.introspection.tags
}
