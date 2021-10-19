locals {
  ec2_arn_prefix = "arn:${join("", data.aws_partition.current.*.partition)}:ec2:${join("", data.aws_region.current.*.name)}:${join("", data.aws_caller_identity.current.*.account_id)}:instance/"
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_region" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  count = local.enabled ? 1 : 0

  statement {
    sid     = "AllowEC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "github-action-runner" {
  count = local.enabled ? 1 : 0

  # Allow EC2 instances to modify their tags — the user-data script will change the Name tag in order to add a dynamic suffix
  statement {
    sid     = "AllowUpdateEC2NameTag"
    actions = ["ec2:CreateTags"]
    resources = [
      "${local.ec2_arn_prefix}*"
    ]
    condition {
      test     = "StringLike"
      values   = ["${module.this.id}-*"]
      variable = "aws:ResourceTag/aws:autoscaling:groupName"
    }
  }

  # Allow EC2 instances to read their designated GitHub PAT from SSM Parameter Store.
  # This assumes that the SSM Parameter uses the alias/aws/ssm KMS Key, and NOT a CMK.
  statement {
    sid     = "AllowGetGitHubToken"
    actions = ["ssm:GetParameters"]
    resources = [
      join("", data.aws_ssm_parameter.github_token.*.arn)
    ]
  }

  statement {
    sid     = "AllowAssumeCICDRole"
    actions = ["sts:AssumeRole"]
    resources = [
      format(module.this.tenant != null ? "arn:${join("", data.aws_partition.current.*.partition)}:iam::%[3]s:role/%[1]s-%[2]s-gbl-identity-cicd" : "arn:${join("", data.aws_partition.current.*.partition)}:iam::%[3]s:role/%[1]s-gbl-identity-cicd", module.this.namespace, module.this.tenant, local.identity_account_id)
    ]
  }

  #bridgecrew:skip=BC_AWS_IAM_64: BC complains about this IAM policy (presumably this statement), even though it's relatively finely scoped.
  #bridgecrew:skip=BC_AWS_IAM_57: see comment for BC_AWS_IAM_64.
  statement {
    sid = "AllowECRActions"
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
  managed_policy_arns = concat([join("", aws_iam_policy.github-action-runner.*.arn), "arn:${join("", data.aws_partition.current.*.partition)}:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.runner_role_additional_policy_arns)
}

resource "aws_iam_instance_profile" "github-action-runner" {
  count = local.enabled ? 1 : 0

  name = module.this.id
  role = aws_iam_role.github-action-runner[0].name
}
