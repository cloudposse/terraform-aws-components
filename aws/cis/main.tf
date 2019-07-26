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
  template_url       = "https://aws-quickstart.s3.amazonaws.com/quickstart-compliance-cis-benchmark/templates/main.template"
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudformation-stack-set.git?ref=tags/0.1.0"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  attributes         = ["${var.attributes}"]
  parameters         = "${var.parameters}"
  template_url       = "${local.template_url}"
  executor_role_name = "${local.executor_role_name}"
  capabilities       = "${var.capabilities}"
}
