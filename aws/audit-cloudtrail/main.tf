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
}

module "cloudtrail" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=tags/0.3.0"
  namespace                     = "${var.namespace}"
  stage                         = "${var.stage}"
  name                          = "${var.name}"
  enable_logging                = "true"
  enable_log_file_validation    = "true"
  include_global_service_events = "true"
  is_multi_region_trail         = "true"
  s3_bucket_name                = "${module.cloudtrail_s3_bucket.bucket_id}"
}

module "cloudtrail_s3_bucket" {
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  region    = "${var.region}"
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
