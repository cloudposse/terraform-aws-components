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
  account_alias  = "${data.terraform_remote_state.account_settings.account_alias}"
  signin_url     = "${data.terraform_remote_state.account_settings.signin_url}"
  admin_group    = ["${data.terraform_remote_state.root_iam.admin_group}", "${data.terraform_remote_state.root_iam.readonly_group}"]
  readonly_group = ["${data.terraform_remote_state.root_iam.readonly_group}"]
}

output "account_alias" {
  value = "${local.account_alias}"
}
