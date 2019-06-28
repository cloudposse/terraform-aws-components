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
  executor_role_name = "cis-executor"
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.3.0"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${local.executor_role_name}"
  use_fullname       = "false"
  attributes         = ["${var.attributes}"]
  role_description   = "IAM Role in all target accounts for Stack Set operations"
  policy_description = "IAM Policy in all target accounts for Stack Set operations"

  principals = {
    AWS = ["${var.administrator_role_arn}"]
  }

  policy_documents = ["${data.aws_iam_policy_document.executor.json}"]
}


data "aws_iam_policy_document" "executor" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "cloudformation:CreateStack",
    ]
  }
}


