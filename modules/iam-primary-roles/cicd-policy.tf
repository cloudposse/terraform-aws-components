data "aws_iam_policy_document" "cicd" {
  statement {
    sid    = "CicdAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    resources = [
      "arn:aws:iam::*:role/*-helm",
      //"arn:aws:iam::*:role/*-terraform",
    ]
  }
  statement {
    sid     = "CicdDenySensitiveAssumeRole"
    effect  = "Deny"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::xxx:role/*"
    ]
  }
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
}

resource "aws_iam_policy" "cicd" {
  name   = format("%s-cicd", module.this.id)
  policy = data.aws_iam_policy_document.cicd.json
}
