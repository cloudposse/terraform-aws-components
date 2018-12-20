resource "aws_organizations_account" "prod" {
  count                      = "${contains(var.accounts_enabled, "prod") == true ? 1 : 0}"
  name                       = "prod"
  email                      = "${format(var.account_email, "prod")}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "prod_account_arn" {
  value = "${join("", aws_organizations_account.prod.*.arn)}"
}

output "prod_account_id" {
  value = "${join("", aws_organizations_account.prod.*.id)}"
}

output "prod_organization_account_access_role" {
  value = "arn:aws:iam::${join("", aws_organizations_account.prod.*.id)}:role/OrganizationAccountAccessRole"
}
