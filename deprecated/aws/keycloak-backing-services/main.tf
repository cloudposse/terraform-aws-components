terraform {
  required_version = "~> 0.11.2"

  backend "s3" {}
}

provider "aws" {
  version = "~> 2.17"

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "dns_zone_name" {
  type        = "string"
  description = "The DNS domain under which to put entries for the database. Usually the same as the cluster name, e.g. us-west-2.prod.cpco.io"
}

variable "chamber_service" {
  default     = "keycloak"
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name_pattern" {
  default     = "/%s/%s"
  description = "Format string for creating SSM parameter name used to store chamber parameters. The default is usually best."
}

variable "chamber_kms_key_id" {
  type        = "string"
  default     = "alias/aws/ssm"
  description = "KMS key ID, ARN, or alias to use for encrypting SSM secrets"
}

data "aws_route53_zone" "default" {
  name = "${var.dns_zone_name}"
}

locals {
  //  availability_zones = ["${split(",", length(var.availability_zones) == 0 ? join(",", data.aws_availability_zones.available.names) : join(",", var.availability_zones))}"]
  chamber_service = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
  dns_zone_id     = "${data.aws_route53_zone.default.zone_id}"
}

resource "aws_ssm_parameter" "keycloak_db_vendor" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_db_vendor")}"
  value       = "mysql"
  description = "Database Vendor, e.g. mysql, postgres"
  type        = "String"
  overwrite   = "true"
}
