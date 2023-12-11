variable "github_actions_iam_actions" {
  type = list(string)
  default = [
    "s3:CreateMultipartUpload",
    "s3:PutObject",
    "s3:PutObjectAcl"
  ]
  description = "List of actions to permit `GitHub OIDC authenticated users` to perform on bucket and bucket prefixes"
}


locals {
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  statement {
    sid       = "AllowS3UploadPermissions"
    effect    = "Allow"
    actions   = var.github_actions_iam_actions
    resources = [module.s3_bucket.bucket_arn, "${module.s3_bucket.bucket_arn}/*"]
  }
}
