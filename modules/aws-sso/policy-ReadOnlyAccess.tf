locals {
  read_only_access_permission_set = [{
    name             = "ReadOnlyAccess",
    description      = "Allow Read Only access to the account",
    relay_state      = "",
    session_duration = "",
    tags             = {},
    inline_policy    = data.aws_iam_policy_document.eks_read_only.json,
    policy_attachments = [
      "arn:${local.aws_partition}:iam::aws:policy/ReadOnlyAccess",
      "arn:${local.aws_partition}:iam::aws:policy/AWSSupportAccess"
    ]
    customer_managed_policy_attachments = []
  }]
}

data "aws_iam_policy_document" "eks_read_only" {
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
