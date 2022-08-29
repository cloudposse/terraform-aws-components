locals {
  ecr_user_enabled = module.this.enabled && var.ecr_user_enabled
}

resource "aws_iam_user" "ecr" {
  count = local.ecr_user_enabled ? 1 : 0
  name  = module.this.id
  tags  = module.this.tags
}

data "aws_iam_policy_document" "ecr_user" {
  count = local.ecr_user_enabled ? 1 : 0

  statement {
    sid       = "ECRGetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_user" {
  count  = local.ecr_user_enabled ? 1 : 0
  name   = module.this.id
  policy = data.aws_iam_policy_document.ecr_user[0].json
}

resource "aws_iam_user_policy_attachment" "ecr_user" {
  count      = local.ecr_user_enabled ? 1 : 0
  user       = aws_iam_user.ecr[0].name
  policy_arn = aws_iam_policy.ecr_user[0].arn
}
