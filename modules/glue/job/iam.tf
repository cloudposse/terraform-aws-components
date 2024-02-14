data "aws_iam_policy_document" "glue_job_aws_tools_access" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "S3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "S3:GetBucketAcl",
      "s3:PutObjectAcl"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ParamStoreReadAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SecretsManagerReadAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "glue_job_aws_tools_access" {
  count = local.enabled ? 1 : 0

  name        = "${module.this.id}-custom-access"
  description = "Policy for Glue jobs to interact with S3 buckets, SSM, Systems Manager Parameter Store, DynamoDB tables and Lambda Functions"
  policy      = one(data.aws_iam_policy_document.glue_job_aws_tools_access.*.json)
}

resource "aws_iam_role_policy_attachment" "glue_jobs_aws_tools_access" {
  count = local.enabled ? 1 : 0

  role       = local.glue_iam_role_name
  policy_arn = one(aws_iam_policy.glue_job_aws_tools_access.*.arn)
}

resource "aws_iam_role_policy_attachment" "glue_redshift_access" {
  count = local.enabled ? 1 : 0

  role       = local.glue_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
