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

module "cloudtrail" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=tags/0.7.0"
  namespace                     = "${var.namespace}"
  stage                         = "${var.stage}"
  name                          = "${var.name}"
  enable_logging                = "true"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "true"
  s3_bucket_name                = "${var.namespace}-audit-account"
  kms_key_id                    = "${var.kms_key_arn}"
}
