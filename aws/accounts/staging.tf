resource "aws_organizations_account" "staging" {
  count                      = "${contains(var.accounts_enabled, "staging") == true ? 1 : 0}"
  name                       = "staging"
  email                      = "${format(var.account_email, "staging")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  staging_account_arn                      = "${join("", aws_organizations_account.staging.*.arn)}"
  staging_account_id                       = "${join("", aws_organizations_account.staging.*.id)}"
  staging_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.staging.*.id)}:role/OrganizationAccountAccessRole"
}

module "staging_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "staging") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/staging/account_id"
      value       = "${local.staging_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/staging/account_arn"
      value       = "${local.staging_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/staging/organization_account_access_role"
      value       = "${local.staging_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organization Account Access Role"
    },
  ]
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
