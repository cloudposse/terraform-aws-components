terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=generalize-principals"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.executor_role_name}"
  use_fullname       = "true"
  attributes         = ["${var.attributes}"]
  role_description   = "IAM Role in all target accounts for Stack Set operations"
  policy_description = "IAM Policy in all target accounts for Stack Set operations"

  principals = {
    AWS = ["${var.administrator_role_arn}"]
  }
}
c
