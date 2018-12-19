terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

data "terraform_remote_state" "root" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-root-terraform-state"
    key    = "accounts/terraform.tfstate"
  }
}
