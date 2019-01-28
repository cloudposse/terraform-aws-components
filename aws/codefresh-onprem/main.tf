terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
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

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

data "terraform_remote_state" "backing_services" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "backing-services/terraform.tfstate"
  }
}

module "codefresh_enterprise_backing_services" {
  source          = "git::https://github.com/cloudposse/terraform-aws-codefresh-backing-services.git?ref=tags/0.1.0"
  namespace       = "${var.namespace}"
  stage           = "${var.stage}"
  vpc_id          = "${data.terraform_remote_state.backing_services.vpc_id}"
  subnet_ids      = ["${data.terraform_remote_state.backing_services.private_subnet_ids}"]
  security_groups = ["${module.kops_metadata.nodes_security_group_id}"]
  zone_name       = "${var.zone_name}"
}
