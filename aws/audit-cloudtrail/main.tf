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
  source                        = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=tags/0.7.0"
  namespace                     = "${var.namespace}"
  stage                         = "${var.stage}"
  name                          = "${var.name}"
  enable_logging                = "true"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "true"
  s3_bucket_name                = "${module.cloudtrail_s3_bucket.bucket_id}"
  kms_key_id                    = "${module.kms_key_s3_bucket.alias_arn}"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.default.arn}"
  cloud_watch_logs_role_arn     = "${module.cloudwatch_logs_role.arn}"
}
