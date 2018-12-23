resource "aws_organizations_account" "dev" {
  count                      = "${contains(var.accounts_enabled, "dev") == true ? 1 : 0}"
  name                       = "dev"
  email                      = "${format(var.account_email, "dev")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  dev_account_arn                      = "${join("", aws_organizations_account.dev.*.arn)}"
  dev_account_id                       = "${join("", aws_organizations_account.dev.*.id)}"
  dev_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.dev.*.id)}:role/OrganizationAccountAccessRole"
}

module "dev_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "dev") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/dev/account_id"
      value       = "${local.dev_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/dev/account_arn"
      value       = "${local.dev_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/dev/organization_account_access_role"
      value       = "${local.dev_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organizational Account Access Role"
    },
  ]
}

output "dev_account_arn" {
  value = "${local.dev_account_arn}"
}

output "dev_account_id" {
  value = "${local.dev_account_id}"
}

output "dev_organization_account_access_role" {
  value = "${local.dev_organization_account_access_role}"
}
