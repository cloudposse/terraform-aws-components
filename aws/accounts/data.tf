resource "aws_organizations_account" "data" {
  count                      = "${contains(var.accounts_enabled, "data") == true ? 1 : 0}"
  name                       = "data"
  email                      = "${format(var.account_email, "data")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  data_account_arn                      = "${join("", aws_organizations_account.data.*.arn)}"
  data_account_id                       = "${join("", aws_organizations_account.data.*.id)}"
  data_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.data.*.id)}:role/OrganizationAccountAccessRole"
}

module "data_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "data") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/data/account_id"
      value       = "${local.data_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/data/account_arn"
      value       = "${local.data_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/data/organization_account_access_role"
      value       = "${local.data_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organization Account Access Role"
    },
  ]
}

output "data_account_arn" {
  value = "${local.data_account_arn}"
}

output "data_account_id" {
  value = "${local.data_account_id}"
}

output "data_organization_account_access_role" {
  value = "${local.data_organization_account_access_role}"
}
