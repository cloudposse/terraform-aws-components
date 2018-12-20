resource "aws_organizations_account" "dev" {
  count                      = "${contains(var.accounts_enabled, "dev") == true ? 1 : 0}"
  name                       = "dev"
  email                      = "${format(var.account_email, "dev")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "dev_account_arn" {
  value = "${join("", aws_organizations_account.dev.*.arn)}"
}

output "dev_account_id" {
  value = "${join("", aws_organizations_account.dev.*.id)}"
}

output "dev_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.dev.id)}:role/OrganizationAccountAccessRole"
}
