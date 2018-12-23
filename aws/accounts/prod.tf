resource "aws_organizations_account" "prod" {
  count                      = "${contains(var.accounts_enabled, "prod") == true ? 1 : 0}"
  name                       = "prod"
  email                      = "${format(var.account_email, "prod")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

locals {
  prod_account_arn                      = "${join("", aws_organizations_account.prod.*.arn)}"
  prod_account_id                       = "${join("", aws_organizations_account.prod.*.id)}"
  prod_organization_account_access_role = "arn:aws:iam::${join("", aws_organizations_account.prod.*.id)}:role/OrganizationAccountAccessRole"
}

module "prod_parameters" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "prod") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/prod/account_id"
      value       = "${local.prod_account_id}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ID"
    },
    {
      name        = "/${var.namespace}/prod/account_arn"
      value       = "${local.prod_account_arn}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Account ARN"
    },
    {
      name        = "/${var.namespace}/prod/organization_account_access_role"
      value       = "${local.prod_organization_account_access_role}"
      type        = "String"
      overwrite   = "true"
      description = "AWS Organizational Account Access Role"
    },
  ]
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
