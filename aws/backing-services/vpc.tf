locals {
  name = "backing-services"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_nat_gateway_enabled" {
  default = "true"
}

variable "vpc_max_subnet_count" {
  default     = 0
  description = "The maximum count of subnets to provision. 0 will provision a subnet for each availability zone within the region"
}

data "aws_region" "current" {}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.2"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${local.name}"
  cidr_block = "${var.vpc_cidr_block}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.8.0"
  availability_zones  = ["${local.availability_zones}"]
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${local.name}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "${var.vpc_nat_gateway_enabled}"
  max_subnet_count    = "${var.vpc_max_subnet_count}"
}

output "vpc_id" {
  description = "VPC ID of backing services"
  value       = "${module.vpc.vpc_id}"
}

output "public_subnet_ids" {
  description = "Public subnet IDs of backing services"
  value       = ["${module.subnets.public_subnet_ids}"]
}

output "private_subnet_ids" {
  description = "Private subnet IDs of backing services"
  value       = ["${module.subnets.private_subnet_ids}"]
}

output "region" {
  description = "AWS region of backing services"
  value       = "${data.aws_region.current.name}"
}
