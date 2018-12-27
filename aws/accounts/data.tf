resource "aws_organizations_account" "data" {
  count                      = "${local.data_count}"
  name                       = "data"
  email                      = "${format(var.account_email, "data")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  data_count                            = "${contains(var.accounts_enabled, "data") == true ? 1 : 0}"
  data_account_arn                      = "${join("", aws_organizations_account.data.*.arn)}"
  data_account_id                       = "${join("", aws_organizations_account.data.*.id)}"
  data_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.data.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "data_account_id" {
  count       = "${local.data_count}"
  name        = "/${var.namespace}/data/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.data_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "data_account_arn" {
  count       = "${local.data_count}"
  name        = "/${var.namespace}/data/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.data_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "data_organization_account_access_role" {
  count       = "${local.data_count}"
  name        = "/${var.namespace}/data/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.data_account_id}"
  overwrite   = "true"
}

output "data_account_arn" {
  value = "${local.data_account_arn}"
}

output "data_account_id" {
  value = "${local.data_account_id}"
}

output "data_organization_account_access_role" {
  value = "${local.data_organization_account_access_role}"
}
