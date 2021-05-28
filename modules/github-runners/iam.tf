data "aws_iam_policy_document" "instance-assume-role-policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "github-action-runner" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      format("arn:aws:iam::%s:role/%s-gbl-identity-cicd", local.identity_account_id, var.namespace)
    ]
  }

  statement {
    actions = [
      # This is intended to be everything except create/delete repository
      # and get/set/delete repositoryPolicy
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DeleteLifecyclePolicy",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:PutLifecyclePolicy",
      "ecr:StartImageScan",
      "ecr:StartLifecyclePolicyPreview",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:UploadLayerPart",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github-action-runner" {
  count = local.enabled ? 1 : 0

  name   = module.this.id
  policy = data.aws_iam_policy_document.github-action-runner[0].json
}

resource "aws_iam_role" "github-action-runner" {
  count = local.enabled ? 1 : 0

  name                = module.this.id
  tags                = module.this.tags
  assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy[0].json
  managed_policy_arns = [aws_iam_policy.github-action-runner[0].arn]
}

resource "aws_iam_instance_profile" "github-action-runner" {
  count = local.enabled ? 1 : 0

  name = module.this.id
  role = aws_iam_role.github-action-runner[0].name
}
