locals {
  enabled                   = module.this.enabled
  github_actions_iam_policy = data.aws_iam_policy_document.github_actions_iam_policy.json

  s3_bucket_arn      = module.s3_bucket.outputs.bucket_arn
  dynamodb_table_arn = module.dynamodb.outputs.table_arn
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  # Allow access to the Dynamodb table used to store TF Plans
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_dynamodb_specific-table.html
  statement {
    sid    = "AllowDynamodbAccess"
    effect = "Allow"
    actions = [
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "AllowDynamodbTableAccess"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = [
      local.dynamodb_table_arn,
      "${local.dynamodb_table_arn}/*"
    ]
  }

  # Allow access to the S3 Bucket used to store TF Plans
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_s3_rw-bucket.html
  statement {
    sid    = "AllowS3Actions"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      local.s3_bucket_arn
    ]
  }
  statement {
    sid    = "AllowS3ObjectActions"
    effect = "Allow"
    actions = [
      "s3:*Object"
    ]
    resources = [
      "${local.s3_bucket_arn}/*"
    ]
  }
}
