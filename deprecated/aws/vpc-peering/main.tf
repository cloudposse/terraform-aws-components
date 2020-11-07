terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

# Fetch the OrganizationAccountAccessRole ARNs from SSM
module "requester_role_arns" {
  enabled        = "${var.enabled}"
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  parameter_read = ["/${var.namespace}/${var.requester_account}/organization_account_access_role"]
}

locals {
  requester_vpc_tags = "${var.requester_vpc_tags}"
  requester_region   = "${var.requester_region}"
  requester_role_arn = "${join("", module.requester_role_arns.values)}"
}

# Fetch the OrganizationAccountAccessRole ARNs from SSM
module "accepter_role_arns" {
  enabled        = "${var.enabled}"
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  parameter_read = ["/${var.namespace}/${var.accepter_account}/organization_account_access_role"]
}

locals {
  accepter_vpc_tags = "${var.accepter_vpc_tags}"
  accepter_region   = "${var.accepter_region}"
  accepter_role_arn = "${join("", module.accepter_role_arns.values)}"
}

module "vpc_peering" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc-peering-multi-account.git?ref=tags/0.1.0"

  enabled = "${var.enabled}"

  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = ["${var.requester_account}", "${var.accepter_account}"]

  auto_accept = true

  # Requester
  requester_vpc_tags            = "${local.requester_vpc_tags}"
  requester_region              = "${local.requester_region}"
  requester_aws_assume_role_arn = "${local.requester_role_arn}"

  # Accepter
  accepter_vpc_tags            = "${local.accepter_vpc_tags}"
  accepter_region              = "${local.accepter_region}"
  accepter_aws_assume_role_arn = "${local.accepter_role_arn}"
}

output "accepter_accept_status" {
  description = "Accepter VPC peering connection request status"
  value       = "${module.vpc_peering.accepter_accept_status}"
}

output "accepter_connection_id" {
  description = "Accepter VPC peering connection ID"
  value       = "${module.vpc_peering.accepter_connection_id}"
}

output "requester_accept_status" {
  description = "Requester VPC peering connection request status"
  value       = "${module.vpc_peering.requester_accept_status}"
}

output "requester_connection_id" {
  description = "Requester VPC peering connection ID"
  value       = "${module.vpc_peering.requester_connection_id}"
}
