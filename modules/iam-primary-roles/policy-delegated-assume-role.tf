locals {
  identity_account_id = local.full_account_map[module.account_map.outputs.identity_account_account_name]
}

data "aws_iam_policy_document" "delegated_assume_role" {
  statement {
    sid     = "DelegatedAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:${local.aws_partition}:iam::*:role/*",
    ]
  }

  statement {
    sid     = "DenyIdentityAssumeRole"
    effect  = "Deny"
    actions = ["sts:AssumeRole"]
    resources = [
      format("arn:%s:iam::%s:role/*", local.aws_partition, local.identity_account_id),
    ]
  }
}

resource "aws_iam_policy" "delegated_assume_role" {
  name        = format("%s-delegatedAssumeRole", module.this.id)
  description = "Allow assume-role to delegated accounts"
  policy      = data.aws_iam_policy_document.delegated_assume_role.json
}
