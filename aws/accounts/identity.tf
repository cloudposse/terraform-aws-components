resource "aws_organizations_account" "identity" {
  count                      = "${contains(var.accounts_enabled, "identity") == true ? 1 : 0}"
  name                       = "identity"
  email                      = "${format(var.account_email, "identity")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  identity_account_arn                      = "${join("", aws_organizations_account.identity.*.arn)}"
  identity_account_id                       = "${join("", aws_organizations_account.identity.*.id)}"
  identity_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.identity.*.id)}:role/OrganizationAccountAccessRole"
}

module "identity_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "identity") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/identity/account_id"
      value       = "${local.identity_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/identity/account_arn"
      value       = "${local.identity_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/identity/organization_account_access_role"
      value       = "${local.identity_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organization Account Access Role"
    },
  ]
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
