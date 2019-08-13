terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `audit`)"
  default     = "audit"
}

variable "name" {
  type        = "string"
  description = "Name (e.g. `account`)"
  default     = "account"
}

variable "region" {
  type        = "string"
  description = "AWS region"
  default     = ""
}

data "aws_region" "default" {}

locals {
  region = "${length(var.region) > 0 ? var.region : data.aws_region.default.name}"
}


data "aws_iam_policy_document" "kms" {
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

module "kms_key" {
  source     = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=0.1.3"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"

  description             = "KMS key for CloudTrail"
  deletion_window_in_days = 10
  enable_key_rotation     = "true"

  policy = "${data.aws_iam_policy_document.kms.json}"
}

module "cloudtrail_s3_bucket" {
  source    = "git::https://github.com/cloudposse/terraform-aws-cloudtrail-s3-bucket.git?ref=0.11/logging"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  region    = "${local.region}"
  sse_algorithm = "aws:kms"
  kms_master_key_arn = "${module.kms_key.alias_arn}"
}

module "cloudtrail" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=tags/0.7.0"
  namespace                     = "${var.namespace}"
  stage                         = "${var.stage}"
  name                          = "${var.name}"
  enable_logging                = "true"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "true"
  s3_bucket_name                = "${module.cloudtrail_s3_bucket.bucket_id}"
  kms_key_id                    = "${module.kms_key.alias_arn}"
}

output "cloudtrail_kms_key_arn" {
  value = "${module.kms_key.alias_arn}"
}

output "cloudtrail_bucket_domain_name" {
  value = "${module.cloudtrail_s3_bucket.bucket_domain_name}"
}

output "cloudtrail_bucket_id" {
  value = "${module.cloudtrail_s3_bucket.bucket_id}"
}

output "cloudtrail_bucket_arn" {
  value = "${module.cloudtrail_s3_bucket.bucket_arn}"
}
