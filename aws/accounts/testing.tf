resource "aws_organizations_account" "testing" {
  count                      = "${contains(var.accounts_enabled, "testing") == true ? 1 : 0}"
  name                       = "testing"
  email                      = "${format(var.account_email, "testing")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  testing_account_arn                      = "${join("", aws_organizations_account.testing.*.arn)}"
  testing_account_id                       = "${join("", aws_organizations_account.testing.*.id)}"
  testing_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.testing.*.id)}:role/OrganizationAccountAccessRole"
}

module "testing_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "testing") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/testing/account_id"
      value       = "${local.testing_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/testing/account_arn"
      value       = "${local.testing_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/testing/organization_account_access_role"
      value       = "${local.testing_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organization Account Access Role"
    },
  ]
}

output "testing_account_arn" {
  value = "${local.testing_account_arn}"
}

output "testing_account_id" {
  value = "${local.testing_account_id}"
}

output "testing_organization_account_access_role" {
  value = "${local.testing_organization_account_access_role}"
}
