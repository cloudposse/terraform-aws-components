resource "aws_organizations_account" "staging" {
  count                      = "${contains(var.accounts_enabled, "staging") == true ? 1 : 0}"
  name                       = "staging"
  email                      = "${format(var.account_email, "staging")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "staging_account_arn" {
  value = "${join("", aws_organizations_account.staging.*.arn)}"
}

output "staging_account_id" {
  value = "${join("", aws_organizations_account.staging.*.id)}"
}

output "staging_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.staging.id)}:role/OrganizationAccountAccessRole"
}
