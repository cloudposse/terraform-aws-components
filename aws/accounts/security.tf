resource "aws_organizations_account" "security" {
  count                      = "${contains(var.accounts_enabled, "security") == true ? 1 : 0}"
  name                       = "security"
  email                      = "${format(var.account_email, "security")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "security_account_arn" {
  value = "${join("", aws_organizations_account.security.*.arn)}"
}

output "security_account_id" {
  value = "${join("", aws_organizations_account.security.*.id)}"
}

output "security_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.security.*.id)}:role/OrganizationAccountAccessRole"
}
