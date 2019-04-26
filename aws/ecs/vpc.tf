variable "availability_zones" {
  type        = "list"
  description = "List of Availability Zones to provision all the resources in"
}

locals {
  name = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.3.4"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${local.name}"
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.8.0"
  availability_zones  = "${var.availability_zones}"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${local.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}
