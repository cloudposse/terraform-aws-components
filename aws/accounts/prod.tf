resource "aws_organizations_account" "prod" {
  count                      = "${local.prod_count}"
  name                       = "prod"
  email                      = "${format(var.account_email, "prod")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  prod_count                            = "${contains(var.accounts_enabled, "prod") == true ? 1 : 0}"
  prod_account_arn                      = "${join("", aws_organizations_account.prod.*.arn)}"
  prod_account_id                       = "${join("", aws_organizations_account.prod.*.id)}"
  prod_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.prod.*.id)}:role/OrganizationAccountAccessRole"
}

resource "aws_ssm_parameter" "prod_account_id" {
  count       = "${local.prod_count}"
  name        = "/${var.namespace}/prod/account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = "${local.prod_account_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "prod_account_arn" {
  count       = "${local.prod_count}"
  name        = "/${var.namespace}/prod/account_arn"
  description = "AWS Account ARN"
  type        = "String"
  value       = "${local.prod_account_arn}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "prod_organization_account_access_role" {
  count       = "${local.prod_count}"
  name        = "/${var.namespace}/prod/organization_account_access_role"
  description = "AWS Organization Account Access Role"
  type        = "String"
  value       = "${local.prod_account_id}"
  overwrite   = "true"
}

output "prod_account_arn" {
  value = "${local.prod_account_arn}"
}

output "prod_account_id" {
  value = "${local.prod_account_id}"
}

output "prod_organization_account_access_role" {
  value = "${local.prod_organization_account_access_role}"
}
