variable "gitops_policy_configuration" {
  type = object({
    s3_bucket_component_name   = optional(string, "gitops/s3-bucket")
    dynamodb_component_name    = optional(string, "gitops/dynamodb")
    s3_bucket_environment_name = optional(string)
    dynamodb_environment_name  = optional(string)
  })
  default     = {}
  nullable    = false
  description = <<-EOT
    Configuration for the GitOps IAM Policy, valid keys are
     - `s3_bucket_component_name` - Component Name of where to store the TF Plans in S3, defaults to `gitops/s3-bucket`
     - `dynamodb_component_name` - Component Name of where to store the TF Plans in Dynamodb, defaults to `gitops/dynamodb`
     - `s3_bucket_environment_name` - Environment name for the S3 Bucket, defaults to current environment
     - `dynamodb_environment_name` - Environment name for the Dynamodb Table, defaults to current environment
  EOT
}

locals {
  gitops_policy_enabled = contains(var.iam_policies, "gitops")
  gitops_policy         = local.gitops_policy_enabled ? one(data.aws_iam_policy_document.gitops_iam_policy.*.json) : null

  s3_bucket_arn      = one(module.s3_bucket[*].outputs.bucket_arn)
  dynamodb_table_arn = one(module.dynamodb[*].outputs.table_arn)
}

module "s3_bucket" {
  count = local.gitops_policy_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = lookup(var.gitops_policy_configuration, "s3_bucket_component_name", "gitops/s3-bucket")
  environment = lookup(var.gitops_policy_configuration, "s3_bucket_environment_name", module.this.environment)

  context = module.this.context
}

module "dynamodb" {
  count = local.gitops_policy_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = lookup(var.gitops_policy_configuration, "dynamodb_component_name", module.this.environment)
  environment = lookup(var.gitops_policy_configuration, "dynamodb_environment_name", module.this.environment)

  context = module.this.context
}

data "aws_iam_policy_document" "gitops_iam_policy" {
  count = local.gitops_policy_enabled ? 1 : 0

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
