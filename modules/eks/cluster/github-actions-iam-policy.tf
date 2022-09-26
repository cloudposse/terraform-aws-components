variable "github_oidc_trusted_role_arns" {
  type        = list(string)
  description = "A list of IAM Role ARNs allowed to assume this cluster's GitHub OIDC role"
  default     = []
}

locals {
  github_role_name          = "gha-oidc"
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json
  github_actions_iam_role_map = [
    {
      rolearn  = aws_iam_role.github_actions[0].arn
      username = module.this.context.tenant != null ? format("%s-%s-%s", module.this.tenant, module.this.stage, local.github_role_name) : format("%s-%s", module.this.stage, local.github_role_name)
      groups = [
        "system:masters"
      ]
    }
  ]
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  # Allows trusted roles to assume this role
  statement {
    sid    = "TrustedRoleAccess"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    resources = var.github_oidc_trusted_role_arns
  }

  # Allow actions on this EKS Cluster
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
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/platform/${module.eks_cluster.eks_cluster_id}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParametersByPath"
    ]
    resources = [
      "*"
    ]
  }
}

