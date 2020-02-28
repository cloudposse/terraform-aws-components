terraform {
  required_version = "~> 0.11.0"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "vpc_peering" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=tags/0.2.0"

  enabled = "${var.enabled}"

  stage      = "${var.stage}"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"

  requestor_vpc_id   = "${var.requestor_vpc_id}"
  requestor_vpc_tags = "${var.requestor_vpc_tags}"
  acceptor_vpc_id    = "${var.acceptor_vpc_id}"
  acceptor_vpc_tags  = "${var.acceptor_vpc_tags}"
  auto_accept        = "${var.auto_accept}"

  acceptor_allow_remote_vpc_dns_resolution  = "${var.acceptor_allow_remote_vpc_dns_resolution}"
  requestor_allow_remote_vpc_dns_resolution = "${var.requestor_allow_remote_vpc_dns_resolution}"
}
