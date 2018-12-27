resource "aws_organizations_account" "testing" {
  count                      = "${local.testing_count}"
  name                       = "testing"
  email                      = "${format(var.account_email, "testing")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  testing_count                            = "${contains(var.accounts_enabled, "testing") == true ? 1 : 0}"
  testing_account_arn                      = "${join("", aws_organizations_account.testing.*.arn)}"
  testing_account_id                       = "${join("", aws_organizations_account.testing.*.id)}"
  testing_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.testing.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "testing_account_id" {
  count       = "${local.testing_count}"
  name        = "/${var.namespace}/testing/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.testing_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "testing_account_arn" {
  count       = "${local.testing_count}"
  name        = "/${var.namespace}/testing/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.testing_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "testing_organization_account_access_role" {
  count       = "${local.testing_count}"
  name        = "/${var.namespace}/testing/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.testing_account_id}"
  overwrite   = "true"
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
