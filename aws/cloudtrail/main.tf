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
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name (e.g. `account`)"
  default     = "account"
}

variable "kms_key_arn" {
  type        = "string"
  description = ""
}

variable "region" {
  type        = "string"
  description = "AWS region"
  default     = ""
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Number of days to retain logs for. CIS recommends 365 days.  Possible/ values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely."
  default     = 365
}

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
  s3_bucket_name                = "${var.namespace}-audit-account"
  kms_key_arn                   = "${var.kms_key_arn}"
  cloud_watch_logs_group_arn    = "${module.logs.log_group_arn}"
  cloud_watch_logs_role_arn     = "${module.logs.role_arn}"
}
