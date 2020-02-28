terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "terraform_remote_state" "cis" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "cis/terraform.tfstate"
  }
}

resource "null_resource" "instances" {
  count = "${var.enabled == "true" ? length(keys(var.cis_instances)) : 0}"

  triggers {
    account = "${join("|", formatlist("%s:%s", element(keys(var.cis_instances), count.index), var.cis_instances[element(keys(var.cis_instances), count.index)]))}"
  }
}

locals {
  raw_instances = ["${split("|", join("|", null_resource.instances.*.triggers.account))}"]
  instances     = "${compact(local.raw_instances)}"
}

resource "aws_cloudformation_stack_set_instance" "default" {
  count               = "${var.enabled == "true" && length(local.instances) > 0 ? length(local.instances) : 0}"
  stack_set_name      = "${data.terraform_remote_state.cis.name}"
  account_id          = "${element(split(":", element(local.instances, count.index)), 0)}"
  region              = "${element(split(":", element(local.instances, count.index)), 1)}"
  parameter_overrides = "${var.parameters}"
}
