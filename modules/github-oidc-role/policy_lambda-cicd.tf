variable "lambda_cicd_policy_configuration" {
  type = object({
    enable_kms_access          = optional(bool, false)
    enable_ssm_access          = optional(bool, false)
    enable_s3_access           = optional(bool, false)
    s3_bucket_component_name   = optional(string, "s3-bucket/github-action-artifacts")
    s3_bucket_environment_name = optional(string)
    s3_bucket_tenant_name      = optional(string)
    s3_bucket_stage_name       = optional(string)
    enable_lambda_update       = optional(bool, false)
  })
  default     = {}
  nullable    = false
  description = <<-EOT
    Configuration for the lambda-cicd policy. The following keys are supported:
      - `enable_kms_access` - (bool) - Whether to allow access to KMS. Defaults to false.
      - `enable_ssm_access` - (bool) - Whether to allow access to SSM. Defaults to false.
      - `enable_s3_access` - (bool) - Whether to allow access to S3. Defaults to false.
      - `s3_bucket_component_name` - (string) - The name of the component to use for the S3 bucket. Defaults to `s3-bucket/github-action-artifacts`.
      - `s3_bucket_environment_name` - (string) - The name of the environment to use for the S3 bucket. Defaults to the environment of the current module.
      - `s3_bucket_tenant_name` - (string) - The name of the tenant to use for the S3 bucket. Defaults to the tenant of the current module.
      - `s3_bucket_stage_name` - (string) - The name of the stage to use for the S3 bucket. Defaults to the stage of the current module.
      - `enable_lambda_update` - (bool) - Whether to allow access to update lambda functions. Defaults to false.
  EOT
}

locals {
  lambda_cicd_policy_enabled = contains(var.iam_policies, "lambda-cicd")
  lambda_cicd_policy         = local.lambda_cicd_policy_enabled ? one(data.aws_iam_policy_document.lambda_cicd_policy.*.json) : null

  lambda_bucket_arn = try(module.s3_artifacts_bucket[0].outputs.bucket_arn, null)
}

module "s3_artifacts_bucket" {
  count = lookup(var.lambda_cicd_policy_configuration, "enable_s3_access", false) ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = lookup(var.lambda_cicd_policy_configuration, "s3_bucket_component_name", "s3-bucket/github-action-artifacts")
  environment = lookup(var.lambda_cicd_policy_configuration, "s3_bucket_environment_name", module.this.environment)
  tenant      = lookup(var.lambda_cicd_policy_configuration, "s3_bucket_tenant_name", module.this.tenant)
  stage       = lookup(var.lambda_cicd_policy_configuration, "s3_bucket_stage_name", module.this.stage)

  context = module.this.context
}

data "aws_iam_policy_document" "lambda_cicd_policy" {
  count = local.lambda_cicd_policy_enabled ? 1 : 0

  dynamic "statement" {
    for_each = lookup(var.lambda_cicd_policy_configuration, "enable_kms_access", false) ? [1] : []
    content {
      sid    = "AllowKMSAccess"
      effect = "Allow"
      actions = [
        "kms:DescribeKey",
        "kms:Encrypt",
      ]
      resources = [
        "*"
      ]
    }
  }

  dynamic "statement" {
    for_each = lookup(var.lambda_cicd_policy_configuration, "enable_ssm_access", false) ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:DescribeParameters",
        "ssm:PutParameter"
      ]
      resources = [
        "arn:aws:ssm:*:*:parameter/lambda/*"
      ]
    }
  }

  dynamic "statement" {
    for_each = lookup(var.lambda_cicd_policy_configuration, "enable_s3_access", false) && local.lambda_bucket_arn != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "s3:HeadObject",
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ]
      resources = [
        local.lambda_bucket_arn,
      ]
    }
  }

  dynamic "statement" {
    for_each = lookup(var.lambda_cicd_policy_configuration, "enable_lambda_update", false) ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration"
      ]
      resources = [
        "*"
      ]
    }
  }
}
