resource "aws_organizations_account" "security" {
  count                      = "${local.security_count}"
  name                       = "security"
  email                      = "${format(var.account_email, "security")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  security_count                            = "${contains(var.accounts_enabled, "security") == true ? 1 : 0}"
  security_account_arn                      = "${join("", aws_organizations_account.security.*.arn)}"
  security_account_id                       = "${join("", aws_organizations_account.security.*.id)}"
  security_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.security.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "security_account_id" {
  count       = "${local.security_count}"
  name        = "/${var.namespace}/security/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.security_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "security_account_arn" {
  count       = "${local.security_count}"
  name        = "/${var.namespace}/security/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.security_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "security_organization_account_access_role" {
  count       = "${local.security_count}"
  name        = "/${var.namespace}/security/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.security_account_id}"
  overwrite   = "true"
}

output "security_account_arn" {
  value = "${local.security_account_arn}"
}

output "security_account_id" {
  value = "${local.security_account_id}"
}

output "security_organization_account_access_role" {
  value = "${local.security_organization_account_access_role}"
}
