locals {
  name = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.3.4"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${local.name}"
  cidr_block = "172.16.0.0/12"
}

locals {
  max_availability_zones = "${length(var.limit_availability_zones) == 0 ? 2 : length(data.aws_availability_zones.available.names)}"
  availability_zones     = "${slice(data.aws_availability_zones.available.names, 0, local.max_availability_zones)}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.3.6"
  availability_zones  = "${local.availability_zones}"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${local.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}
