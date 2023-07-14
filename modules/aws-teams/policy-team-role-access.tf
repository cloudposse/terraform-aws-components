locals {
  identity_account_id = local.full_account_map[module.account_map.outputs.identity_account_account_name]
}

data "aws_iam_policy_document" "team_role_access" {
  statement {
    sid    = "TeamRoleAccess"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]
    resources = [
      "arn:${local.aws_partition}:iam::*:role/*",
    ]
  }

  statement {
    sid       = "GetCallerIdentity"
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "team_role_access" {
  name        = format("%s-TeamRoleAccess", module.this.id)
  description = "IAM permission to use AssumeRole"
  policy      = data.aws_iam_policy_document.team_role_access.json
  tags        = module.this.tags
}
