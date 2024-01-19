resource "aws_iam_policy" "glue_job_aws_tools_access" {
  name        = "${module.this.id}-custom-access"
  description = "Policy for Glue jobs to interact with S3 buckets, SSM, Systems Manager Parameter Store, DynamoDB tabels and Lambda Functions."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3BucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "S3:GetBucketAcl",
        "s3:PutObjectAcl"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ParamStoreReadAccess",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerReadAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:ListSecrets"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBTableAccess",
      "Effect": "Allow",
      "Action": [
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
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_jobs_aws_tools_access" {
  role       = local.glue_iam_role_name
  policy_arn = aws_iam_policy.glue_job_aws_tools_access.arn
}

resource "aws_iam_role_policy_attachment" "glue_redshift_access" {
  role       = local.glue_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
