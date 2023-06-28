# This policy adds additional permission required to apply a limited set of Terraform
# resources in the `core-identity` account. We do not want to grant the full
# admin access to `core-identity` so that we do not allow users to lock themselves out.

locals {
  extended_poweruser_policy_enabled = contains(local.configured_policies, "extended_poweruser")
}

data "aws_iam_policy_document" "extended_poweruser" {
  count = local.extended_poweruser_policy_enabled ? 1 : 0

  statement {
    sid    = "ExtendedPowerUserAccess"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "extended_poweruser" {
  count = local.extended_poweruser_policy_enabled ? 1 : 0

  name   = format("%s-extended-poweruser", module.this.id)
  policy = data.aws_iam_policy_document.extended_poweruser[0].json

  tags = module.this.tags
}
