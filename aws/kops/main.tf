terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "aws_availability_zones" "default" {}

locals {
  chamber_service             = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
  computed_availability_zones = "${data.aws_availability_zones.default.names}"
  distinct_availability_zones = "${distinct(compact(concat(var.availability_zones, local.computed_availability_zones)))}"

  # Concatenate the predefined AZs with the computed AZs and select the first N distinct AZs. 
  availability_zones      = "${slice(local.distinct_availability_zones, 0, var.availability_zone_count)}"
  availability_zone_count = "${length(local.availability_zones)}"
}

module "kops_state_backend" {
  source           = "git::https://github.com/cloudposse/terraform-aws-kops-state-backend.git?ref=tags/0.1.5"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.name}"
  attributes       = ["${var.kops_attribute}"]
  cluster_name     = "${var.region}"
  parent_zone_name = "${var.zone_name}"
  zone_name        = "${var.complete_zone_name}"
  domain_enabled   = "${var.domain_enabled}"
  force_destroy    = "${var.force_destroy}"
  region           = "${var.region}"
}

module "ssh_key_pair" {
  source              = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.3.0"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  attributes          = ["${var.region}"]
  ssh_public_key_path = "${var.ssh_public_key_path}"
  generate_ssh_key    = "true"
}

# Allocate one large subnet for each AZ, plus one additional one for the utility subnets.
module "private_subnets" {
  source       = "subnets"
  iprange      = "${var.network_cidr}"
  newbits      = "${var.private_subnets_newbits > 0 ? var.private_subnets_newbits : local.availability_zone_count}"
  netnum       = "${var.private_subnets_netnum}"
  subnet_count = "${local.availability_zone_count+1}"
}

# Divide up the first private subnet and use it for the utility subnet
module "utility_subnets" {
  source       = "subnets"
  iprange      = "${module.private_subnets.cidrs[0]}"
  newbits      = "${var.utility_subnets_newbits > 0 ? var.utility_subnets_newbits : local.availability_zone_count}"
  netnum       = "${var.utility_subnets_netnum}"
  subnet_count = "${local.availability_zone_count}"
}

locals {
  private_subnets = "${join(",", slice(module.private_subnets.cidrs, 1, local.availability_zone_count+1))}"
  utility_subnets = "${join(",", module.utility_subnets.cidrs)}"
}

# These parameters correspond to the kops manifest template:
# Read more: <https://github.com/cloudposse/geodesic/blob/master/rootfs/templates/kops/default.yaml>

resource "aws_ssm_parameter" "kops_cluster_name" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_cluster_name")}"
  value       = "${module.kops_state_backend.zone_name}"
  description = "Kops cluster name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_state_store" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_state_store")}"
  value       = "s3://${module.kops_state_backend.bucket_name}"
  description = "Kops state store S3 bucket name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_state_store_region" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_state_store_region")}"
  value       = "${module.kops_state_backend.bucket_region}"
  description = "Kops state store (S3 bucket) region"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_ssh_public_key_path" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_ssh_public_key_path")}"
  value       = "${module.ssh_key_pair.public_key_filename}"
  description = "Kops SSH public key filename path"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_ssh_private_key_path" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_ssh_private_key_path")}"
  value       = "${module.ssh_key_pair.private_key_filename}"
  description = "Kops SSH private key filename path"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_dns_zone" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_dns_zone")}"
  value       = "${module.kops_state_backend.zone_name}"
  description = "Kops DNS zone name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_network_cidr" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_network_cidr")}"
  value       = "${var.network_cidr}"
  description = "CIDR block of the kops virtual network"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_private_subnets" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_private_subnets")}"
  value       = "${local.private_subnets}"
  description = "Kops private subnet CIDRs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_utility_subnets" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_utility_subnets")}"
  value       = "${local.utility_subnets}"
  description = "Kops utility subnet CIDRs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_non_masquerade_cidr" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_non_masquerade_cidr")}"
  value       = "${var.kops_non_masquerade_cidr}"
  description = "The CIDR range for Pod IPs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_availability_zones" {
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_availability_zones")}"
  value       = "${join(",", local.availability_zones)}"
  description = "Kops availability zones in which cluster will be provisioned"
  type        = "String"
  overwrite   = "true"
}
