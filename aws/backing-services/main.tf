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

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "zone_id" {
  type        = "string"
  description = "DNS zone ID"
}

data "aws_availability_zones" "available" {}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "kops_metadata" {
  source   = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.1.1"
  dns_zone = "${var.region}.${var.zone_name}"
}
