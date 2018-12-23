resource "aws_organizations_account" "security" {
  count                      = "${contains(var.accounts_enabled, "security") == true ? 1 : 0}"
  name                       = "security"
  email                      = "${format(var.account_email, "security")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  security_account_arn                      = "${join("", aws_organizations_account.security.*.arn)}"
  security_account_id                       = "${join("", aws_organizations_account.security.*.id)}"
  security_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.security.*.id)}:role/OrganizationAccountAccessRole"
}

module "security_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "security") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/security/account_id"
      value       = "${local.security_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/security/account_arn"
      value       = "${local.security_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/security/organization_account_access_role"
      value       = "${local.security_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organizational Account Access Role"
    },
  ]
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
