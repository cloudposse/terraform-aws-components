resource "aws_organizations_account" "audit" {
  count                      = "${local.audit_count}"
  name                       = "audit"
  email                      = "${format(var.account_email, "audit")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  audit_count                            = "${contains(var.accounts_enabled, "audit") == true ? 1 : 0}"
  audit_account_arn                      = "${join("", aws_organizations_account.audit.*.arn)}"
  audit_account_id                       = "${join("", aws_organizations_account.audit.*.id)}"
  audit_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.audit.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "audit_account_id" {
  count       = "${local.audit_count}"
  name        = "/${var.namespace}/audit/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.audit_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "audit_account_arn" {
  count       = "${local.audit_count}"
  name        = "/${var.namespace}/audit/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.audit_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "audit_organization_account_access_role" {
  count       = "${local.audit_count}"
  name        = "/${var.namespace}/audit/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.audit_account_id}"
  overwrite   = "true"
}

output "audit_account_arn" {
  value = "${local.audit_account_arn}"
}

output "audit_account_id" {
  value = "${local.audit_account_id}"
}

output "audit_organization_account_access_role" {
  value = "${local.audit_organization_account_access_role}"
}
