terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

# Lookup VPC of the kops cluster
module "kops_metadata" {
  source         = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=tags/0.2.1"
  enabled        = "${var.enabled}"
  dns_zone       = "${var.region}.${var.zone_name}"
  vpc_tag        = "${var.vpc_tag}"
  vpc_tag_values = ["${var.vpc_tag_values}"]
}

module "kops_legacy_account_vpc_peering" {
  source  = "git::https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account.git?ref=tags/0.5.0"
  enabled = "${var.enabled}"

  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${var.name}"

  auto_accept = true

  # Requester
  requester_vpc_id              = "${module.kops_metadata.vpc_id}"
  requester_region              = "${var.region}"
  requester_aws_assume_role_arn = "${var.aws_assume_role_arn}"

  # Accepter
  accepter_vpc_id              = "${var.legacy_account_vpc_id}"
  accepter_region              = "${var.legacy_account_region}"
  accepter_aws_assume_role_arn = "${var.legacy_account_assume_role_arn}"
}
