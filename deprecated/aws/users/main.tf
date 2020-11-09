terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "terraform_remote_state" "account_settings" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "account-settings/terraform.tfstate"
  }
}

data "terraform_remote_state" "root_iam" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "root-iam/terraform.tfstate"
  }
}

locals {
  accounts_enabled = "${concat(list("root"), var.accounts_enabled)}"
}

# Fetch the OrganizationAccountAccessRole ARNs from SSM
module "admin_groups" {
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  parameter_read = "${formatlist("/${var.namespace}/%s/admin_group", local.accounts_enabled)}"
}

locals {
  account_alias           = "${data.terraform_remote_state.account_settings.account_alias}"
  signin_url              = "${data.terraform_remote_state.account_settings.signin_url}"
  admin_groups            = ["${module.admin_groups.values}"]
  readonly_groups         = ["${data.terraform_remote_state.root_iam.readonly_group}"]
  minimum_password_length = "${data.terraform_remote_state.account_settings.minimum_password_length}"
}

output "account_alias" {
  description = "AWS IAM Account Alias"
  value       = "${local.account_alias}"
}

output "signin_url" {
  description = "AWS Signin URL"
  value       = "${local.signin_url}"
}
