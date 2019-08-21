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

resource "aws_default_security_group" "default" {
  vpc_id = "${module.kops_metadata.vpc_id}"

  tags = {
    Name = "Default Security Group"
  }
}
