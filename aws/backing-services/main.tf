terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "identity" {
  source = "git::git@github.com:cloudposse/terraform-aws-account-metadata.git?ref=tags/0.1.2"
}

module "kops_metadata" {
  source   = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.1.1"
  dns_zone = "${module.identity.aws_region}.${module.identity.zone_name}"
}
