module "kms_key_cloudtrail" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  description             = "KMS key for CloudTrail"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = join("", data.aws_iam_policy_document.kms_key_cloudtrail[*].json)

  context = module.this.context
}

data "aws_caller_identity" "this" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_iam_policy_document" "kms_key_cloudtrail" {
  count = local.enabled ? 1 : 0

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
        format("arn:${join("", data.aws_partition.current[*].partition)}:iam::%s:root", join("", data.aws_caller_identity.this[*].account_id))
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
        format("arn:${join("", data.aws_partition.current[*].partition)}:cloudtrail:*:%s:trail/*", join("", data.aws_caller_identity.this[*].account_id))
      ]
    }
  }
}
