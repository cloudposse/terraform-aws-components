locals {
  enabled = module.this.enabled
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.5"

  stream_names           = var.stream_names
  retention_in_days      = var.retention_in_days
  principals             = var.principals
  additional_permissions = var.additional_permissions
  kms_key_arn            = module.kms_key_logs.key_arn

  context = module.this.context
}

module "kms_key_logs" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = "KMS key for CloudWatch Logs"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  alias                   = "alias/${module.this.id}"
  policy                  = join("", data.aws_iam_policy_document.kms.*.json)

  context = module.this.context
}

data "aws_iam_policy_document" "kms" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "EnableRootUserPermissions"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:Tag*",
      "kms:Untag*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:${join("", data.aws_partition.current[*].partition)}:iam::${join("", data.aws_caller_identity.current[*].account_id)}:root"
      ]
    }
  }

  statement {
    sid    = "Allow CloudWatch to Encrypt with the key"
    effect = "Allow"

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.region}.amazonaws.com",
      ]
    }
  }
}
