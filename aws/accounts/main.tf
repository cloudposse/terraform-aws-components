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

variable "account_role_name" {
  type        = "string"
  description = "IAM role that Organization automatically preconfigures in the new member account"
  default     = "OrganizationAccountAccessRole"
}

variable "account_email" {
  type        = "string"
  description = "Email address format for accounts (e.g. `%s@cloudposse.co`)"
}

variable "account_iam_user_access_to_billing" {
  type        = "string"
  description = "If set to `ALLOW`, the new account enables IAM users to access account billing information if they have the required permissions. If set to `DENY`, then only the root user of the new account can access account billing information"
  default     = "DENY"
}

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
