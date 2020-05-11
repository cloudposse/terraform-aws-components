terraform {
  backend "s3" {}
}

data "aws_availability_zones" "available" {}

data "aws_route53_zone" "default" {
  name = var.kops_cluster_name
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.2.0"
  enabled      = true
  cluster_name = var.kops_cluster_name
}

locals {
  null               = ""
  zone_id            = data.aws_route53_zone.default.zone_id
  availability_zones = split(",", length(var.elasticache_availability_zones) == 0 ? join(",", data.aws_availability_zones.available.names) : join(",", var.elasticache_availability_zones))
  chamber_service    = var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service

  chamber_parameter_format = "/%s/%s"
}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

resource "random_string" "sentry_secret_key" {
  length  = 48
  special = true
}

resource "random_string" "sentry_admin_user_password" {
  length  = 21
  special = false
}

resource "aws_ssm_parameter" "sentry_secret" {
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_secret")
  value       = random_string.sentry_secret_key.result
  description = "Secret Key for Sentry to encrypt sessions"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "sentry_admin_user_password" {
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_admin_user_password")
  value       = random_string.sentry_admin_user_password.result
  description = "Password for Sentry admin user"
  type        = "String"
  overwrite   = true
}
