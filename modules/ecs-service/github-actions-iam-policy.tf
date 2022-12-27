variable "github_oidc_trusted_role_arns" {
  type        = list(string)
  description = "A list of IAM Role ARNs allowed to assume this cluster's GitHub OIDC role"
  default     = []
}

locals {
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  # Allows trusted roles to assume this role
  statement {
    sid    = "TrustedRoleAccess"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    resources = var.github_oidc_trusted_role_arns
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
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter${format("/%s/%s/*", var.chamber_service, var.name)}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "*"
    ]
  }
}
