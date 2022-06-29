locals {
  aws_partition = join("", data.aws_partition.current[*].partition)
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
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

data "aws_iam_policy_document" "github_action_runner" {
  count = local.enabled ? 1 : 0

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
      format(module.this.tenant != null ? "arn:${local.aws_partition}:iam::%[3]s:role/%[1]s-%[2]s-gbl-identity-cicd" : "arn:${local.aws_partition}:iam::%[3]s:role/%[1]s-gbl-identity-cicd", module.this.namespace, module.this.tenant, local.identity_account_id)
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

resource "aws_iam_policy" "github_action_runner" {
  count = local.enabled ? 1 : 0

  name   = module.this.id
  policy = data.aws_iam_policy_document.github_action_runner[0].json
}

resource "aws_iam_role" "github_action_runner" {
  count = local.enabled ? 1 : 0

  name                = module.this.id
  tags                = module.introspection.tags
  assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy[0].json
  managed_policy_arns = concat([join("", aws_iam_policy.github_action_runner.*.arn), "arn:${local.aws_partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"], var.runner_role_additional_policy_arns)
}

resource "aws_iam_instance_profile" "github_action_runner" {
  count = local.enabled ? 1 : 0

  name = module.this.id
  role = aws_iam_role.github_action_runner[0].name
}
