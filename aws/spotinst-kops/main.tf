provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "spotinst" {
  #token   = "${module.token.value}"
  token = var.spotinst_token

  # account = "${module.account_id.value}"
  account = var.spotinst_account_id
}

module "account_id" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=init"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_account_id
  override_value  = var.override_account_id
}

module "token" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-chamber-reader.git?ref=init"

  enabled         = var.enabled
  chamber_format  = var.chamber_format
  chamber_service = var.chamber_service
  parameter       = var.chamber_name_token
  override_value  = var.override_token
}

data "aws_region" "current" {
}

locals {
  cluster_name = "${data.aws_region.current.name}.${var.zone_name}"
}

module "kops_metadata_networking" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.2.0"
  enabled      = var.enabled
  cluster_name = local.cluster_name
}

module "kops_metadata_launch_configurations" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-launch-configurations.git?ref=init"
  enabled      = var.enabled
  cluster_name = local.cluster_name
}

resource "spotinst_ocean_aws" "default" {
  region = data.aws_region.current.name

  name = local.cluster_name

  controller_id = local.cluster_name

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnet_ids = module.kops_metadata_networking.private_subnet_ids

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  security_groups = [module.kops_metadata_networking.nodes_security_group_id]

  whitelist = var.instance_types

  image_id  = "ami-07a64e50756d630d8"
  user_data = ""
  key_name  = ""

  tags {
    key   = "Cluster"
    value = join("", keys(values(module.kops_metadata_launch_configurations.test)))
  }
}

