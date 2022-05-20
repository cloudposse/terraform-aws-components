locals {
  root_account_id     = local.full_account_map[module.account_map.outputs.root_account_account_name]
  identity_account_id = local.full_account_map[module.account_map.outputs.identity_account_account_name]
  audit_account_id    = local.full_account_map[module.account_map.outputs.audit_account_account_name]
}

data "aws_iam_policy_document" "delegated_assume_role" {
  statement {
    sid     = "DelegatedAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::*:role/*",
    ]
  }

  statement {
    sid     = "DenyIdentityRootAssumeRole"
    effect  = "Deny"
    actions = ["sts:AssumeRole"]
    resources = [
      format("arn:aws:iam::%s:role/*", local.root_account_id),
      format("arn:aws:iam::%s:role/*", local.identity_account_id),
      format("arn:aws:iam::%s:role/*", local.audit_account_id),
    ]
  }
}

resource "aws_iam_policy" "delegated_assume_role" {
  name        = format("%s-delegatedAssumeRole", module.this.id)
  description = "Allow assume-role to delegated accounts"
  policy      = data.aws_iam_policy_document.delegated_assume_role.json

  tags = module.introspection.tags
}
