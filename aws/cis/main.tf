terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

resource "null_resource" "instances" {
  count = "${var.enabled == "true" ? length(keys(var.cis_instances)) : 0}"

  triggers {
    account = "${join("|", formatlist("%s:%s", element(keys(var.cis_instances), count.index), var.cis_instances[element(keys(var.cis_instances), count.index)]))}"
  }
}

locals {
  executor_role_name = "cis-executor"
  template_url = "https://aws-quickstart.s3.amazonaws.com/quickstart-compliance-cis-benchmark/templates/main.template"
  instances = ["${split("|", join("|", null_resource.instances.*.triggers.account))}"]
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudformation-stack-set.git?ref=init"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  attributes         = ["${var.attributes}"]
  template_url = "${local.template_url}"
  executor_role_name = "${local.executor_role_name}"
}

resource "aws_cloudformation_stack_set_instance" "default" {
  count          = "${var.enabled == "true" ? length(local.instances) : 0}"
  stack_set_name = "${module.default.name}"
  account_id     = "${element(split(":", element(local.instances, count.index)), 0)}"
  region         = "${element(split(":", element(local.instances, count.index)), 1)}"

}
