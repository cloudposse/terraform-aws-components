resource "aws_organizations_account" "default" {
  count                      = "${local.count}"
  name                       = "${var.stage}"
  email                      = "${format(var.account_email, var.stage)}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  count                            = "${contains(var.accounts_enabled, var.stage) == true ? 1 : 0}"
  account_arn                      = "${join("", aws_organizations_account.default.*.arn)}"
  account_id                       = "${join("", aws_organizations_account.default.*.id)}"
  organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.default.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "account_id" {
  count       = "${local.count}"
  name        = "/${var.namespace}/${var.stage}/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "account_arn" {
  count       = "${local.count}"
  name        = "/${var.namespace}/${var.stage}/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "organization_account_access_role" {
  count       = "${local.count}"
  name        = "/${var.namespace}/${var.stage}/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.organization_account_access_role}"
  overwrite   = "true"
}
