# NOTE: Organization can only be created from the master account
# https://www.terraform.io/docs/providers/aws/r/organizations_organization.html

terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "organization_feature_set" {
  type        = "string"
  default     = "ALL"
  description = "`ALL` (default) or `CONSOLIDATED_BILLING`"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

resource "aws_organizations_organization" "default" {
  feature_set = "${var.organization_feature_set}"
}

output "organization_id" {
  value = "${aws_organizations_organization.default.id}"
}

output "organization_arn" {
  value = "${aws_organizations_organization.default.arn}"
}

output "organization_master_account_id" {
  value = "${aws_organizations_organization.default.master_account_id}"
}

output "organization_master_account_arn" {
  value = "${aws_organizations_organization.default.master_account_arn}"
}

output "organization_master_account_email" {
  value = "${aws_organizations_organization.default.master_account_email}"
}
