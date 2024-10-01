terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

data "aws_availability_zones" "default" {}

locals {
  chamber_service             = var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service
  computed_availability_zones = data.aws_availability_zones.default.names
  distinct_availability_zones = distinct(compact(concat(var.availability_zones, local.computed_availability_zones)))

  # If we are creating the VPC, concatenate the predefined AZs with the computed AZs and select the first N distinct AZs.
  # If we are using a shared VPC, use the availability zones dictated by the VPC
  availability_zones = split(",", var.create_vpc == "true" ? join(",", slice(local.distinct_availability_zones, 0, var.availability_zone_count)) : join("", data.aws_ssm_parameter.availability_zones.*.value))

  availability_zone_count = length(local.availability_zones)
}

module "kops_state_backend" {
  source           = "git::https://github.com/cloudposse/terraform-aws-kops-state-backend.git?ref=tags/0.3.0"
  namespace        = var.namespace
  stage            = var.stage
  name             = var.name
  attributes       = ["${var.kops_attribute}"]
  cluster_name     = coalesce(var.cluster_name_prefix, var.resource_region, var.region)
  parent_zone_name = var.zone_name
  zone_name        = var.complete_zone_name
  domain_enabled   = var.domain_enabled
  force_destroy    = var.force_destroy
  region           = coalesce(var.state_store_region, var.region)
  create_bucket    = var.create_state_store_bucket
}

module "ssh_key_pair" {
  source               = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-ssh-key-pair.git?ref=tags/0.2.0"
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = ["${coalesce(var.resource_region, var.region)}"]
  ssm_path_prefix      = local.chamber_service
  rsa_bits             = var.ssh_key_rsa_bits
  ssh_key_algorithm    = var.ssh_key_algorithm
  ecdsa_curve          = var.ssh_key_ecdsa_curve
  ssh_public_key_name  = "kops_ssh_public_key"
  ssh_private_key_name = "kops_ssh_private_key"
}

# Allocate one large subnet for each AZ, plus one additional one for the utility subnets.
module "private_subnets" {
  source       = "subnets"
  iprange      = local.vpc_network_cidr
  newbits      = var.private_subnets_newbits > 0 ? var.private_subnets_newbits : local.availability_zone_count
  netnum       = var.private_subnets_netnum
  subnet_count = local.availability_zone_count + 1
}

# Divide up the first private subnet and use it for the utility subnet
module "utility_subnets" {
  source       = "subnets"
  iprange      = module.private_subnets.cidrs[0]
  newbits      = var.utility_subnets_newbits > 0 ? var.utility_subnets_newbits : local.availability_zone_count
  netnum       = var.utility_subnets_netnum
  subnet_count = local.availability_zone_count
}

#######
# If create_vpc is not true, then we import all the VPC configuration from the VPC chamber service
#
data "aws_ssm_parameter" "vpc_id" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "vpc_id")
}

data "aws_ssm_parameter" "vpc_cidr_block" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "cidr_block")
}

###
# The following are lists, and must all be the same size and in the same order
#
data "aws_ssm_parameter" "availability_zones" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "availability_zones")
}

# List of NAT gateways from private subnet to public, one per subnet, which is one per availability zone
data "aws_ssm_parameter" "nat_gateways" {
  count = var.create_vpc == "false" && var.use_shared_nat_gateways == "true" ? 1 : 0
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "nat_gateways")
}

# List of private subnet CIDR blocks, one per availability zone
data "aws_ssm_parameter" "private_subnet_cidrs" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "private_subnet_cidrs")
}

# List of private subnet AWS IDs, one per availability zone
data "aws_ssm_parameter" "private_subnet_ids" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "private_subnet_ids")
}

# List of public subnet CIDR blocks, one per availability zone
data "aws_ssm_parameter" "public_subnet_cidrs" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "public_subnet_cidrs")
}

# List of public subnet AWS IDs, one per availability zone
data "aws_ssm_parameter" "public_subnet_ids" {
  count = var.create_vpc == "true" ? 0 : 1
  name  = format(var.vpc_chamber_parameter_name, var.vpc_chamber_service, var.vpc_parameter_prefix, "public_subnet_ids")
}

#
# End of VPC data import
######

locals {
  vpc_network_cidr     = var.create_vpc == "true" ? var.network_cidr : join("", data.aws_ssm_parameter.vpc_cidr_block.*.value)
  private_subnet_cidrs = var.create_vpc == "true" ? join(",", slice(module.private_subnets.cidrs, 1, local.availability_zone_count + 1)) : join("", data.aws_ssm_parameter.private_subnet_cidrs.*.value)
  utility_subnet_cidrs = var.create_vpc == "true" ? join(",", module.utility_subnets.cidrs) : join("", data.aws_ssm_parameter.public_subnet_cidrs.*.value)
}

# These parameters correspond to the kops manifest template:
# Read more: <https://github.com/cloudposse/geodesic/blob/master/rootfs/templates/kops/default.yaml>

resource "aws_ssm_parameter" "kops_cluster_name" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_cluster_name")
  value       = module.kops_state_backend.zone_name
  description = "Kops cluster name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_state_store" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_state_store")
  value       = "s3://${module.kops_state_backend.bucket_name}"
  description = "Kops state store S3 bucket name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_state_store_region" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_state_store_region")
  value       = module.kops_state_backend.bucket_region
  description = "Kops state store (S3 bucket) region"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_dns_zone" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_dns_zone")
  value       = module.kops_state_backend.zone_name
  description = "Kops DNS zone name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_dns_zone_id" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_dns_zone_id")
  value       = module.kops_state_backend.zone_id
  description = "Kops DNS zone ID"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_network_cidr" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_network_cidr")
  value       = local.vpc_network_cidr
  description = "CIDR block of the kops virtual network"
  type        = "String"
  overwrite   = "true"
}

# If we are using a shared VPC, we save its AWS ID here. If kops is creating the VPC, we do not export the ID
resource "aws_ssm_parameter" "kops_shared_vpc_id" {
  count       = var.create_vpc == "true" ? 0 : 1
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_shared_vpc_id")
  value       = join("", data.aws_ssm_parameter.vpc_id.*.value)
  description = "Kops (shared) VPC AWS ID"
  type        = "String"
  overwrite   = "true"
}

# If we are using a shared VPC, we save the list of NAT gateway IDs here. If kops is creating the VPC, we do not export the IDs
resource "aws_ssm_parameter" "kops_shared_nat_gateways" {
  count       = var.create_vpc == "true" ? 0 : 1
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_shared_nat_gateways")
  value       = var.use_shared_nat_gateways == "true" ? join("", data.aws_ssm_parameter.nat_gateways.*.value) : replace(local.private_subnet_cidrs, "/[^,]+/", "External")
  description = "Kops (shared) private subnet NAT gateway AWS IDs"
  type        = "String"
  overwrite   = "true"
}

# If we are using a shared VPC, we save the list of private subnet IDs here. If kops is creating the VPC, we do not export the IDs
resource "aws_ssm_parameter" "kops_shared_private_subnet_ids" {
  count       = var.create_vpc == "true" ? 0 : 1
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_shared_private_subnet_ids")
  value       = join("", data.aws_ssm_parameter.private_subnet_ids.*.value)
  description = "Kops private subnet AWS IDs"
  type        = "String"
  overwrite   = "true"
}

# If we are using a shared VPC, we save the list of utility (public) subnet IDs here. If kops is creating the VPC, we do not export the IDs
resource "aws_ssm_parameter" "kops_shared_utility_subnet_ids" {
  count       = var.create_vpc == "true" ? 0 : 1
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_shared_utility_subnet_ids")
  value       = join("", data.aws_ssm_parameter.public_subnet_ids.*.value)
  description = "Kops utility subnet AWS IDs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_private_subnets" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_private_subnets")
  value       = local.private_subnet_cidrs
  description = "Kops private subnet CIDRs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_utility_subnets" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_utility_subnets")
  value       = local.utility_subnet_cidrs
  description = "Kops utility subnet CIDRs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_non_masquerade_cidr" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_non_masquerade_cidr")
  value       = var.kops_non_masquerade_cidr
  description = "The CIDR range for Pod IPs"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "kops_availability_zones" {
  name        = format(var.chamber_parameter_name, local.chamber_service, "kops_availability_zones")
  value       = join(",", local.availability_zones)
  description = "Kops availability zones in which cluster will be provisioned"
  type        = "String"
  overwrite   = "true"
}
