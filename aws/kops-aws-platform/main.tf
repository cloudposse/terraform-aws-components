terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.1.1"
  enabled      = "${var.flow_logs_enabled}"
  cluster_name = "${var.region}.${var.zone_name}"
}

module "kops_metadata_iam" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.1.0"
  cluster_name = "${var.region}.${var.zone_name}"
}

resource "aws_default_security_group" "default" {
  # If kops is using a shared VPC, then it is likely that the kops_metadata module will
  # return an empty vpc_id, in which case we will leave it to the VPC owner to manage
  # the default security group.
  count = "${module.kops_metadata.vpc_id == "" ? 0 : 1}"

  vpc_id = "${module.kops_metadata.vpc_id}"

  tags = {
    Name = "Default Security Group"
  }
}

locals {
  chamber_parameter_format = "/%s/%s"
}
