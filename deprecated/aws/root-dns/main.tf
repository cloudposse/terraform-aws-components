terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {}

variable "accounts_enabled" {
  type        = "list"
  description = "Accounts to enable"
  default     = ["dev", "staging", "prod", "testing", "audit"]
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}
