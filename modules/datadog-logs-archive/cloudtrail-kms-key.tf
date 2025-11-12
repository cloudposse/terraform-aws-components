locals {
  kms_enabled    = local.enabled && var.enable_kms_encryption
  create_kms_key = local.kms_enabled && var.create_kms_key && var.kms_key_arn == null
  kms_key_arn    = local.kms_enabled ? (var.kms_key_arn != null ? var.kms_key_arn : try(module.kms_key_cloudtrail[0].key_arn, null)) : null
}

module "kms_key_cloudtrail" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  count = local.create_kms_key ? 1 : 0

  description             = "KMS key for CloudTrail logs (datadog-logs-archive)"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_cloudtrail[0].json

  context = module.this.context
}

data "aws_iam_policy_document" "kms_key_cloudtrail" {
  count = local.create_kms_key ? 1 : 0

  statement {
    sid    = "Allow the account identity to manage the KMS key"
    effect = "Allow"

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        format("arn:${local.aws_partition}:iam::%s:root", local.aws_account_id)
      ]
    }
  }

  statement {
    sid    = "Allow CloudTrail to encrypt with the KMS key"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        format("arn:${local.aws_partition}:cloudtrail:*:%s:trail/*", local.aws_account_id)
      ]
    }
  }
}
