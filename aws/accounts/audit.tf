resource "aws_organizations_account" "audit" {
  count                      = "${contains(var.accounts_enabled, "audit") == true ? 1 : 0}"
  name                       = "audit"
  email                      = "${format(var.account_email, "audit")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "audit_account_arn" {
  value = "${join("", aws_organizations_account.audit.*.arn)}"
}

output "audit_account_id" {
  value = "${join("", aws_organizations_account.audit.*.id)}"
}

output "audit_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.audit.id)}:role/OrganizationAccountAccessRole"
}
