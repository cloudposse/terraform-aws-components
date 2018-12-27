resource "aws_organizations_account" "identity" {
  count                      = "${local.identity_count}"
  name                       = "identity"
  email                      = "${format(var.account_email, "identity")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  identity_count                            = "${contains(var.accounts_enabled, "identity") == true ? 1 : 0}"
  identity_account_arn                      = "${join("", aws_organizations_account.identity.*.arn)}"
  identity_account_id                       = "${join("", aws_organizations_account.identity.*.id)}"
  identity_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.identity.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "identity_account_id" {
  count       = "${local.identity_count}"
  name        = "/${var.namespace}/identity/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.identity_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "identity_account_arn" {
  count       = "${local.identity_count}"
  name        = "/${var.namespace}/identity/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.identity_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "identity_organization_account_access_role" {
  count       = "${local.identity_count}"
  name        = "/${var.namespace}/identity/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.identity_account_id}"
  overwrite   = "true"
}

output "identity_account_arn" {
  value = "${local.identity_account_arn}"
}

output "identity_account_id" {
  value = "${local.identity_account_id}"
}

output "identity_organization_account_access_role" {
  value = "${local.identity_organization_account_access_role}"
}
