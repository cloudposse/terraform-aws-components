terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

locals {
  region = "${length(var.region) > 0 ? var.region : data.aws_region.default.name}"
}

module "cloudtrail" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=tags/0.7.1"
  namespace                     = "${var.namespace}"
  stage                         = "${var.stage}"
  name                          = "${var.name}"
  enable_logging                = "true"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "true"
  s3_bucket_name                = "${module.cloudtrail_s3_bucket.bucket_id}"
  kms_key_arn                   = "${module.kms_key_cloudtrail.alias_arn}"
  cloud_watch_logs_group_arn    = "${module.logs.log_group_arn}"
  cloud_watch_logs_role_arn     = "${module.logs.role_arn}"
}

module "kms_key_cloudtrail" {
  source    = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.1.3"
  namespace = "${var.namespace}"
  name      = "${var.name}"
  stage     = "${var.stage}"

  description             = "KMS key for CloudTrail"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"

  policy = "${data.aws_iam_policy_document.kms_key_cloudtrail.json}"
}

data "aws_iam_policy_document" "kms_key_cloudtrail" {
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
        "arn:aws:cloudtrail:*:*:trail/*",
      ]
    }
  }
}
