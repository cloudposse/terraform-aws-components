resource "aws_organizations_account" "dev" {
  count                      = "${local.dev_count}"
  name                       = "dev"
  email                      = "${format(var.account_email, "dev")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  dev_count                            = "${contains(var.accounts_enabled, "dev") == true ? 1 : 0}"
  dev_account_arn                      = "${join("", aws_organizations_account.dev.*.arn)}"
  dev_account_id                       = "${join("", aws_organizations_account.dev.*.id)}"
  dev_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.dev.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "dev_account_id" {
  count       = "${local.dev_count}"
  name        = "/${var.namespace}/dev/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.dev_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "dev_account_arn" {
  count       = "${local.dev_count}"
  name        = "/${var.namespace}/dev/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.dev_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "dev_organization_account_access_role" {
  count       = "${local.dev_count}"
  name        = "/${var.namespace}/dev/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.dev_account_id}"
  overwrite   = "true"
}

output "dev_account_arn" {
  value = "${local.dev_account_arn}"
}

output "dev_account_id" {
  value = "${local.dev_account_id}"
}

output "dev_organization_account_access_role" {
  value = "${local.dev_organization_account_access_role}"
}
