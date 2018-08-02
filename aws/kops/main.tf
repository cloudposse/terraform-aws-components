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

variable "ssh_public_key_path" {
  type        = "string"
  description = "SSH public key path to write master public/private key pair for cluster"
  default     = "/secrets/tf/ssh"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "kops_state_backend" {
  source           = "git::https://github.com/cloudposse/terraform-aws-kops-state-backend.git?ref=tags/0.1.3"
  namespace        = "${var.namespace}"
  stage            = "${var.stage}"
  name             = "${var.name}"
  attributes       = "state"
  cluster_name     = "${var.region}"
  parent_zone_name = "${var.zone_name}"
  zone_name        = "$${name}.$${parent_zone_name}"
  region           = "${var.region}"
}

module "ssh_key_pair" {
  source              = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.2.3"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  attributes          = "${var.region}"
  ssh_public_key_path = "${var.ssh_public_key_path}"
  generate_ssh_key    = "true"
}
