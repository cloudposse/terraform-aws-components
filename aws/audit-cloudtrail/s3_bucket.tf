data "aws_iam_policy_document" "kms_key_s3_bucket" {
  statement {
    sid    = "Allow CloudTrail to Encrypt with the key"
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey*",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        "arn:aws:cloudtrail:*:*:trail/*"
      ]
    }
  }
}

module "kms_key_s3_bucket" {
  source     = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=0.1.3"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"

  description             = "KMS key for CloudTrail"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"

  policy = "${data.aws_iam_policy_document.kms_key_s3_bucket.json}"
}

module "cloudtrail_s3_bucket" {
  source    = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-s3-bucket.git?ref=0.11/logging"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  region    = "${local.region}"
  sse_algorithm = "aws:kms"
  kms_master_key_arn = "${module.kms_key_s3_bucket.alias_arn}"
}
