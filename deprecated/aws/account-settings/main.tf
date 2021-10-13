terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "account_settings" {
  source    = "git::https://github.com/cloudposse/terraform-aws-iam-account-settings.git?ref=tags/0.1.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"
  enabled   = "${var.enabled}"

  minimum_password_length = "${var.minimum_password_length}"
}
