resource "aws_organizations_account" "staging" {
  count                      = "${local.staging_count}"
  name                       = "staging"
  email                      = "${format(var.account_email, "staging")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  staging_count                            = "${contains(var.accounts_enabled, "staging") == true ? 1 : 0}"
  staging_account_arn                      = "${join("", aws_organizations_account.staging.*.arn)}"
  staging_account_id                       = "${join("", aws_organizations_account.staging.*.id)}"
  staging_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.staging.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "staging_account_id" {
  count       = "${local.staging_count}"
  name        = "/${var.namespace}/staging/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.staging_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "staging_account_arn" {
  count       = "${local.staging_count}"
  name        = "/${var.namespace}/staging/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.staging_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "staging_organization_account_access_role" {
  count       = "${local.staging_count}"
  name        = "/${var.namespace}/staging/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.staging_account_id}"
  overwrite   = "true"
}

output "staging_account_arn" {
  value = "${local.staging_account_arn}"
}

output "staging_account_id" {
  value = "${local.staging_account_id}"
}

output "staging_organization_account_access_role" {
  value = "${local.staging_organization_account_access_role}"
}
