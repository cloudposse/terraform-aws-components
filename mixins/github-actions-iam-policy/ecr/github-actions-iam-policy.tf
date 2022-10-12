locals {
  github_actions_iam_policy = join("", data.aws_iam_policy_document.github_actions_iam_policy.*.json)
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  count = var.github_actions_iam_role_enabled ? 1 : 0

  # Permissions copied from https://docs.aws.amazon.com/AmazonECR/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonEC2ContainerRegistryPowerUser
  # This policy grants administrative permissions that allow IAM users to read and write to repositories,
  # but doesn't allow them to delete repositories or change the policy documents that are applied to them.
  statement {
    sid    = "AmazonEC2ContainerRegistryPowerUser"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]

    #bridgecrew:skip=BC_AWS_IAM_57:OK to allow write access to all ECRs because ECRs have their own access policies
    # and this policy prohibits the user from making changes to the access policy.
    resources = ["*"]
  }
}
