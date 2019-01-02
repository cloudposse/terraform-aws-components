terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name  (e.g. `kops`)"
  default     = "kops"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "domain_enabled" {
  type        = "string"
  description = "Enable DNS Zone creation for kops"
  default     = "true"
}

variable "force_destroy" {
  type        = "string"
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without errors. These objects are not recoverable."
  default     = "false"
}

variable "ssh_public_key_path" {
  type        = "string"
  description = "SSH public key path to write master public/private key pair for cluster"
  default     = "/secrets/tf/ssh"
}

variable "kops_attribute" {
  type        = "string"
  description = "Additional attribute to kops state bucket"
  default     = "state"
}

variable "complete_zone_name" {
  type        = "string"
  description = "Region or any classifier prefixed to zone name"
  default     = "$${name}.$${parent_zone_name}"
}

variable "private_subnets_cidr" {
  default = "172.20.32.0/16"
}

variable "private_subnets_newbits" {
  default = "3"
}

variable "private_subnets_netnum" {
  default = "0"
}

variable "utility_subnets_cidr" {
  default = "172.20.0.0/16"
}

variable "utility_subnets_newbits" {
  default = "6"
}

variable "utility_subnets_netnum" {
  default = "0"
}

variable "chamber_service" {
  default = ""
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
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

module "private_subnets" {
  source  = "subnets"
  iprange = "${var.private_subnets_cidr}"
  newbits = "${var.private_subnets_newbits}"
  netnum  = "${var.private_subnets_netnum}"
}

module "utility_subnets" {
  source  = "subnets"
  iprange = "${var.utility_subnets_cidr}"
  newbits = "${var.utility_subnets_newbits}"
  netnum  = "${var.utility_subnets_netnum}"
}

variable "chamber_parameter_name" {
  default = "/%s/%s"
}

locals {
  chamber_service = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
}

module "chamber_parameters" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"

  parameter_write = [
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_cluster_name")}"
      value       = "${module.kops_state_backend.zone_name}"
      type        = "String"
      overwrite   = "true"
      description = "Kops cluster name"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_state_store")}"
      value       = "s3://${module.kops_state_backend.bucket_name}"
      type        = "String"
      overwrite   = "true"
      description = "Kops state store (S3 bucket) URL"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_state_store_region")}"
      value       = "s3://${module.kops_state_backend.bucket_region}"
      type        = "String"
      overwrite   = "true"
      description = "Kops state store (S3 bucket) region"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_ssh_public_key_path")}"
      value       = "${module.ssh_key_pair.public_key_filename}"
      type        = "String"
      overwrite   = "true"
      description = "Kops SSH public key filename path"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_ssh_private_key_path")}"
      value       = "${module.ssh_key_pair.private_key_filename}"
      type        = "String"
      overwrite   = "true"
      description = "Kops SSH private key filename path"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_dns_zone")}"
      value       = "${module.kops_state_backend.zone_name}"
      type        = "String"
      overwrite   = "true"
      description = "Kops cluster name"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_private_subnets")}"
      value       = "${module.private_subnets.cidrs}"
      type        = "String"
      overwrite   = "true"
      description = "Kops private subnet CIDRs"
    },
    {
      name        = "${format(var.chamber_parameter_name, local.chamber_service, "kops_utility_subnets")}"
      value       = "${module.utility_subnets.cidrs}"
      type        = "String"
      overwrite   = "true"
      description = "Kops utility subnet CIDRs"
    },
  ]
}
