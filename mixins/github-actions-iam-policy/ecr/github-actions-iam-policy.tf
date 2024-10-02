locals {
  enabled                   = module.this.enabled
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json
  ecr_resources_static      = [for k, v in module.ecr.repository_arn_map : v]
  ecr_resources_wildcard    = [for k, v in module.ecr.repository_arn_map : "${v}/*"]
  resources                 = concat(local.ecr_resources_static, local.ecr_resources_wildcard)
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  statement {
    sid    = "AllowECRPermissions"
    effect = "Allow"
    actions = [
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
    resources = local.resources
  }

  # required as minimum permissions for pushing and logging into a public ECR repository
  # https://github.com/aws-actions/amazon-ecr-login#permissions
  # https://docs.aws.amazon.com/AmazonECR/latest/public/docker-push-ecr-image.html
  statement {
    sid    = "AllowEcrGetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
}
