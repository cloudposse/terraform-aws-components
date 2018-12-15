terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

locals {
  # hack for `count of` cannot be computed fix
  bucket_name = "${var.namespace}-${var.stage}-${var.name}"
}

module "bucket" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-s3-log-storage.git?ref=tags/0.3.1"
  enabled                = "${var.enabled}"
  name                   = "${var.name}"
  stage                  = "${var.stage}"
  namespace              = "${var.namespace}"
  lifecycle_rule_enabled = "false"
}

module "user" {
  source       = "git::https://github.com/cloudposse/terraform-aws-iam-s3-user.git?ref=tags/0.1.2"
  namespace    = "${var.namespace}"
  stage        = "${var.stage}"
  name         = "${var.name}"
  s3_actions   = ["s3:*"]
  s3_resources = ["arn:aws:s3:::${local.bucket_name}", "arn:aws:s3:::${local.bucket_name}/*"]
}
