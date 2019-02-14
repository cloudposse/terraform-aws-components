terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "terraform_remote_state" "accounts" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "accounts/terraform.tfstate"
  }
}

module "kops_admin_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "kops"
  stage      = "${var.stage}"
  attributes = ["admin"]
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "true"
}

module "kops_readonly_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "kops"
  stage      = "${var.stage}"
  attributes = ["readonly"]
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "true"
}
