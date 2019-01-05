terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
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

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

data "aws_availability_zones" "available" {}

data "aws_route53_zone" "default" {
  name = "${var.zone_name}"
}

locals {
  null = ""
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  chamber_service             = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}
