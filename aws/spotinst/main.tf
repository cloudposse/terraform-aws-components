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
  template_url       = "https://s3.amazonaws.com/spotinst-public/assets/cloudformation/templates/spotinst_aws_cfn_account_credentials_iam_stack.template.json"
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudformation-stack.git?ref=init"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  attributes         = ["${var.attributes}"]
  parameters         = "${var.parameters}"
  template_url       = "${local.template_url}"
  capabilities       = "${var.capabilities}"
}
