locals {
  enabled_accounts = concat(var.corp_eks_accounts, var.corp_non_eks_accounts)
}

resource "aws_organizations_organization" "default" {
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = "ALL"
}

resource "aws_organizations_account" "default" {
  for_each                   = toset(local.enabled_accounts)
  name                       = each.key
  email                      = format(var.account_email_format, each.key)
  iam_user_access_to_billing = var.account_iam_user_access_to_billing
  tags                       = module.this.tags
}
