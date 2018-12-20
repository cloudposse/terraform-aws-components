terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
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

locals {
  audit_account_id   = "${data.terraform_remote_state.accounts.audit_account_id}"
  dev_account_id     = "${data.terraform_remote_state.accounts.dev_account_id}"
  prod_account_id    = "${data.terraform_remote_state.accounts.prod_account_id}"
  staging_account_id = "${data.terraform_remote_state.accounts.staging_account_id}"
  testing_account_id = "${data.terraform_remote_state.accounts.testing_account_id}"
}
