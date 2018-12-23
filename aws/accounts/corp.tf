resource "aws_organizations_account" "corp" {
  count                      = "${contains(var.accounts_enabled, "corp") == true ? 1 : 0}"
  name                       = "corp"
  email                      = "${format(var.account_email, "corp")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  corp_account_arn                      = "${join("", aws_organizations_account.corp.*.arn)}"
  corp_account_id                       = "${join("", aws_organizations_account.corp.*.id)}"
  corp_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.corp.*.id)}:role/OrganizationAccountAccessRole"
}

module "corp_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "corp") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/corp/account_id"
      value       = "${local.corp_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/corp/account_arn"
      value       = "${local.corp_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/corp/organization_account_access_role"
      value       = "${local.corp_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organizational Account Access Role"
    },
  ]
}

output "corp_account_arn" {
  value = "${local.corp_account_arn}"
}

output "corp_account_id" {
  value = "${local.corp_account_id}"
}

output "corp_organization_account_access_role" {
  value = "${local.corp_organization_account_access_role}"
}
