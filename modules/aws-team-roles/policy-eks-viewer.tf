locals {
  eks_viewer_enabled = contains(local.configured_policies, "eks_viewer")
  account_name       = lookup(module.this.descriptors, "account_name", module.this.stage)
  account_number     = module.account_map.outputs.full_account_map[local.account_name]
}

data "aws_iam_policy_document" "eks_view_access" {
  count = local.eks_viewer_enabled ? 1 : 0

  statement {
    sid    = "AllowEKSView"
    effect = "Allow"
    actions = [
      "eks:Get*",
      "eks:Describe*",
      "eks:List*",
      "eks:Access*"
    ]
    resources = [
      "*"
    ]
  }

}

data "aws_iam_policy_document" "eks_viewer_access_aggregated" {
  count = local.eks_viewer_enabled ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.eks_view_access[0].json,
  ]
}

resource "aws_iam_policy" "eks_viewer" {
  count = local.eks_viewer_enabled ? 1 : 0

  name   = format("%s-eks_viewer", module.this.id)
  policy = data.aws_iam_policy_document.eks_viewer_access_aggregated[0].json

  tags = module.this.tags
}
