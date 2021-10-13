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

data "aws_vpc" "default" {
  default = "true"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Name = "Default Security Group"
  }
}

module "flow_logs" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc-flow-logs-s3-bucket.git?ref=tags/0.1.0"

  name       = "vpc"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
  attributes = "${concat(list("default"), var.attributes, list("flow-logs"))}"
  delimiter  = "${var.delimiter}"

  region = "${var.region}"

  enabled = "${var.flow_logs_enabled}"

  vpc_id = "${data.aws_vpc.default.id}"
}
