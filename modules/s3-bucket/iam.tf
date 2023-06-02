data "aws_iam_policy_document" "custom_policy" {
  count = local.enabled && var.custom_policy_enabled ? 1 : 0

  statement {
    actions = var.custom_policy_actions

    resources = [
      "${module.s3_bucket.bucket_arn}",
      "${module.s3_bucket.bucket_arn}/*"
    ]
    principals {
      identifiers = length(local.custom_policy_account_arns) > 0 ? local.custom_policy_account_arns : ["*"]
      type        = "AWS"
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "log_delivery_policy" {
  count = local.enabled && var.log_delivery_policy_enabled ? 1 : 0

  statement {
    sid       = "AWSLogDeliveryWrite"
    effect    = "Allow"
    resources = ["${module.s3_bucket.bucket_arn}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSLogDeliveryAclCheck"
    effect    = "Allow"
    resources = [module.s3_bucket.bucket_arn]
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}