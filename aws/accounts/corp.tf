resource "aws_organizations_account" "corp" {
  count                      = "${contains(var.accounts_enabled, "corp") == true ? 1 : 0}"
  name                       = "corp"
  email                      = "${format(var.account_email, "corp")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "corp_account_arn" {
  value = "${join("", aws_organizations_account.corp.*.arn)}"
}

output "corp_account_id" {
  value = "${join("", aws_organizations_account.corp.*.id)}"
}

output "corp_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.corp.*.id)}:role/OrganizationAccountAccessRole"
}
