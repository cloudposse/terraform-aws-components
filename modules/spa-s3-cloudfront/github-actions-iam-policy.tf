locals {
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  statement {
    sid    = "BucketActions"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload"
    ]
    resources = [module.spa_web.s3_bucket_arn]
  }

  statement {
    sid    = "ObjectActions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl"
    ]
    resources = [format("%s/*", module.spa_web.s3_bucket_arn)]
  }

  statement {
    sid    = "CloudfrontActions"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      module.spa_web.cf_arn
    ]
  }
}
