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

data "aws_iam_policy_document" "support_access_trusted_advisor" {
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
  arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}

data "aws_iam_policy_document" "support_access_aggregated" {
  source_json   = data.aws_iam_policy.aws_support_access.policy
  override_json = data.aws_iam_policy_document.support_access_trusted_advisor.json
}

resource "aws_iam_policy" "support" {
  name   = format("%s-support", module.this.id)
  policy = data.aws_iam_policy_document.support_access_aggregated.json
}
