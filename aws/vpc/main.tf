terraform {
  required_version = "~> 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

provider "null" {
  version = "~> 2.1"
}

locals {
  chamber_service = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"

  # Work around limitation that conditional operator cannot be used with lists. https://github.com/hashicorp/terraform/issues/18259
  availability_zones = "${split("|", length(var.availability_zones) == 0 ? join("|", data.aws_availability_zones.available.names) : join("|", var.availability_zones))}"
}

module "parameter_prefix" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = ""
  stage      = ""
  name       = "${var.name}"
  attributes = "${var.attributes}"
  delimiter  = "_"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  cidr_block = "${var.vpc_cidr_block}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.12.3"
  availability_zones   = "${local.availability_zones}"
  max_subnet_count     = "${var.max_subnet_count}"
  namespace            = "${var.namespace}"
  stage                = "${var.stage}"
  name                 = "${var.name}"
  vpc_id               = "${module.vpc.vpc_id}"
  igw_id               = "${module.vpc.igw_id}"
  cidr_block           = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled  = "${var.vpc_nat_gateway_enabled}"
  nat_instance_enabled = "${var.vpc_nat_instance_enabled}"
  nat_instance_type    = "${var.vpc_nat_instance_type}"
  attributes           = "${var.attributes}"
  tags                 = "${var.tags}"
}

resource "aws_ssm_parameter" "vpc_id" {
  description = "VPC ID of backing services"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "vpc_id")}"
  value       = "${module.vpc.vpc_id}"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "igw_id" {
  description = "VPC ID of backing services"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "igw_id")}"
  value       = "${module.vpc.igw_id}"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "cidr_block" {
  description = "VPC ID of backing services"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "cidr_block")}"
  value       = "${module.vpc.vpc_cidr_block}"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "availability_zones" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "availability_zones")}"
  value       = "${join(",", local.availability_zones)}"
  description = "VPC subnet availability zones"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "nat_gateways" {
  count       = "${var.vpc_nat_gateway_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "nat_gateways")}"
  value       = "${join(",", module.subnets.nat_gateway_ids)}"
  description = "VPC private NAT gateways"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "nat_instances" {
  count       = "${var.vpc_nat_instance_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "nat_instances")}"
  value       = "${join(",", module.subnets.nat_instance_ids)}"
  description = "VPC private NAT instances"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "private_subnet_cidrs" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "private_subnet_cidrs")}"
  value       = "${join(",", module.subnets.private_subnet_cidrs)}"
  description = "VPC private subnet CIDRs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "private_subnet_ids")}"
  value       = "${join(",", module.subnets.private_subnet_ids)}"
  description = "VPC private subnet AWS IDs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "public_subnet_cidrs" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "public_subnet_cidrs")}"
  value       = "${join(",", module.subnets.public_subnet_cidrs)}"
  description = "VPC public subnet CIDRs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, module.parameter_prefix.id, "public_subnet_ids")}"
  value       = "${join(",", module.subnets.public_subnet_ids)}"
  description = "VPC public subnet AWS IDs"
  type        = "String"
  overwrite   = "true"
}
