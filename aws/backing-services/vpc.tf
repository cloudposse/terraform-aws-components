locals {
  name = "backing-services"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_nat_gateway_enabled" {
  default = "true"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${local.name}"
  cidr_block = "${var.vpc_cidr_block}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.3.4"
  availability_zones  = ["${data.aws_availability_zones.available.names}"]
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${local.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "${var.vpc_nat_gateway_enabled}"
}
