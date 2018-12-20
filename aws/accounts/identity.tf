resource "aws_organizations_account" "identity" {
  count                      = "${contains(var.accounts_enabled, "identity") == true ? 1 : 0}"
  name                       = "identity"
  email                      = "${format(var.account_email, "identity")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "identity_account_arn" {
  value = "${join("", aws_organizations_account.identity.*.arn)}"
}

output "identity_account_id" {
  value = "${join("", aws_organizations_account.identity.*.id)}"
}

output "identity_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.identity.*.id)}:role/OrganizationAccountAccessRole"
}
