resource "aws_organizations_account" "data" {
  count                      = "${contains(var.accounts_enabled, "data") == true ? 1 : 0}"
  name                       = "data"
  email                      = "${format(var.account_email, "data")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "data_account_arn" {
  value = "${join("", aws_organizations_account.data.*.arn)}"
}

output "data_account_id" {
  value = "${join("", aws_organizations_account.data.*.id)}"
}

output "data_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.data.*.id)}:role/OrganizationAccountAccessRole"
}
