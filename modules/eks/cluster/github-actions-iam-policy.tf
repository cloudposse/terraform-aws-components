locals {
  github_role_name          = "gha-oidc"
  github_actions_iam_policy = local.github_actions_iam_role_enabled ? data.aws_iam_policy_document.github_actions_iam_policy[0].json : ""
  github_actions_iam_role_map = local.github_actions_iam_role_enabled ? [
    {
      rolearn  = aws_iam_role.github_actions[0].arn
      username = module.this.context.tenant != null ? format("%s-%s-%s", module.this.tenant, module.this.stage, local.github_role_name) : format("%s-%s", module.this.stage, local.github_role_name)
      groups = [
        "system:masters"
      ]
    }
  ] : []
}

#bridgecrew:skip=BC_AWS_IAM_57: This policy provides no write access, so complaint about unconstrained write access is incorrect.
data "aws_iam_policy_document" "github_actions_iam_policy" {
  count = local.github_actions_iam_role_enabled ? 1 : 0 # Allow actions on this EKS Cluster
  statement {
    sid    = "AllowEKSActions"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = [module.eks_cluster.eks_cluster_arn]
  }

  # Allow chamber to read secrets
  statement {
    sid    = "AllowKMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/platform/${module.eks_cluster.eks_cluster_id}/*"
    ]
  }
}

