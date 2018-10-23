terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "terraform_remote_state" "root_iam" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "root-iam/terraform.tfstate"
  }
}

data "aws_iam_account_alias" "default" {}

output "account_alias" {
  value = "${data.aws_iam_account_alias.default.account_alias}"
}

locals {
  admin_group = ["${data.terraform_remote_state.root_iam.admin_group}", "${data.terraform_remote_state.root_iam.readonly_group}"]
  readonly_group = ["${data.terraform_remote_state.root_iam.readonly_group}"]
}
