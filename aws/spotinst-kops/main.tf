terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

provider "spotinst" {
  token = "${module.token.value}"
  account = "${module.account_id.value}"
}

module "account_id" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=init"

  enabled         = "${var.enabled}"
  chamber_format  = "${var.chamber_format}"
  chamber_service = "${var.chamber_service}"
  parameter       = "${var.chamber_name_account_id}"
  override_value  = "${var.override_account_id}"
}

module "token" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=init"

  enabled         = "${var.enabled}"
  chamber_format  = "${var.chamber_format}"
  chamber_service = "${var.chamber_service}"
  parameter       = "${var.chamber_name_token}"
  override_value  = "${var.override_token}"
}

data "aws_region" "current" {}

locals {
  cluster_name = "${data.aws_region.current.name}.${var.zone_name}"
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.1.1"
  enabled      = "${var.enabled}"
  cluster_name = "${local.cluster_name}"
}


resource "spotinst_ocean_aws" "default" {
  region = "${data.aws_region.current.name}"

  name = "${local.cluster_name}"

  controller_id = "${local.cluster_name}"

  autoscaler "resource_limits" {
    max_vcpu = 100000
    max_memory_gib = 20000
  }

  subnet_ids = ["${module.kops_metadata.private_subnet_ids}"]
  security_groups = ["${module.kops_metadata.nodes_security_group_id}"]

  whitelist = ["${var.instance_types}"]


  image_id = "ami-07a64e50756d630d8"
  user_data = ""
  key_name = ""

  tags = {
    "key" = "Cluster"
    "value" = ""
  }
}

