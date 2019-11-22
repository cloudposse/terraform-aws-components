variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones to provision all the resources in"
}

variable "nat_gateway_enabled" {
  type        = string
  description = "Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet"
  default     = false
}

variable "nat_instance_enabled" {
  type        = string
  description = "Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet"
  default     = true
}

variable "nat_instance_type" {
  type        = string
  description = "NAT Instance type"
  default     = "t3.micro"
}

locals {
  name = var.region
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = local.name
  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.18.1"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = local.name
  region               = var.region
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = var.nat_gateway_enabled
  nat_instance_enabled = var.nat_instance_enabled
  nat_instance_type    = var.nat_instance_type
}
