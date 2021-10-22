locals {
  eks_cluster_oidc_issuer_url = module.eks.outputs["eks_cluster_identity_oidc_issuer"]
}

module "eks_iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.2.2"

  enabled = local.enabled_iam_role

  iam_source_json_url   = var.iam_source_json_url
  iam_policy_statements = var.iam_policy_statements

  context = module.this.context
}

module "eks_iam_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "0.10.3"

  enabled = local.enabled_iam_role

  aws_iam_policy_document     = local.enabled_iam_role ? join("", data.aws_iam_policy_document.github_action_runner.*.json) : "{}"
  eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url
  service_account_name        = var.service_account_name
  service_account_namespace   = var.service_account_namespace

  depends_on = [
    data.aws_iam_policy_document.github_action_runner
  ]

  context = module.this.context
}

data "aws_iam_policy_document" "github_action_runner" {
  count = local.enabled_iam_role ? 1 : 0

  statement {
    sid    = "EcrReadWriteDeleteAccess"
    effect = "Allow"

    actions = [
      # This is intended to be everything except create/delete repository
      # and get/set/delete repositoryPolicy
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:PutImageTagMutability",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:StartImageScan",
      "ecr:BatchDeleteImage",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:GetLifecyclePolicy",
      "ecr:PutLifecyclePolicy",
      "ecr:StartLifecyclePolicyPreview",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:DeleteLifecyclePolicy",
      "ecr:PutImageScanningConfiguration",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AssumeRoles"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    effect    = "Allow"
    resources = [module.iam_primary_roles.outputs.role_name_role_arn_map["cicd"]]
  }

  statement {
    sid = "AllowGithubActionRunnersSSMAccess"

    actions = [
      "ssm:DescribeParameters"
    ]

    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "AllowGithubActionRunnersSSMReadAccess"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    effect = "Allow"

    resources = [
      format(
        "arn:%s:ssm:%s:%s:parameter/github-action/secrets/*",
        data.aws_partition.current.partition,
        var.region,
        data.aws_caller_identity.current.account_id
      )
    ]
  }
}

data "aws_iam_policy_document" "github_action_runner_kms" {
  count = local.enabled_iam_role ? 1 : 0

  statement {
    sid = "AllowGithubActionRunnersToDecrypt"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*"
    ]

    effect = "Allow"
    resources = [
      aws_kms_key.github_action_runner[0].arn
    ]
  }
}

resource "aws_iam_policy" "github_action_runner_kms" {
  count = local.enabled_iam_role ? 1 : 0

  name        = "github_action_runner_kms"
  description = "Grants github-runners access to kms"

  policy = data.aws_iam_policy_document.github_action_runner_kms[0].json

  tags = module.this.tags
}

resource "aws_iam_role_policy_attachment" "github_action_runner_kms" {
  count = local.enabled_iam_role ? 1 : 0

  role       = module.eks_iam_role.service_account_role_name
  policy_arn = aws_iam_policy.github_action_runner_kms[0].arn
}
