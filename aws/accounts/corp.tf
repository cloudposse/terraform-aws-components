resource "aws_organizations_account" "corp" {
  count                      = "${local.corp_count}"
  name                       = "corp"
  email                      = "${format(var.account_email, "corp")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  corp_count                            = "${contains(var.accounts_enabled, "corp") == true ? 1 : 0}"
  corp_account_arn                      = "${join("", aws_organizations_account.corp.*.arn)}"
  corp_account_id                       = "${join("", aws_organizations_account.corp.*.id)}"
  corp_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.corp.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "corp_account_id" {
  count       = "${local.corp_count}"
  name        = "/${var.namespace}/corp/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.corp_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "corp_account_arn" {
  count       = "${local.corp_count}"
  name        = "/${var.namespace}/corp/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.corp_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "corp_organization_account_access_role" {
  count       = "${local.corp_count}"
  name        = "/${var.namespace}/corp/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.corp_account_id}"
  overwrite   = "true"
}

output "corp_account_arn" {
  value = "${local.corp_account_arn}"
}

output "corp_account_id" {
  value = "${local.corp_account_id}"
}

output "corp_organization_account_access_role" {
  value = "${local.corp_organization_account_access_role}"
}
