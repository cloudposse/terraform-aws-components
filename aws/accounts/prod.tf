variable "prod_account_name" {
  type        = "string"
  description = "Production account name"
  default     = "prod"
}

variable "prod_account_email" {
  type        = "string"
  description = "Production account email"
}

resource "aws_organizations_account" "prod" {
  name                       = "${var.prod_account_name}"
  email                      = "${var.prod_account_email}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "prod_account_arn" {
  value = "${aws_organizations_account.prod.arn}"
}

output "prod_account_id" {
  value = "${aws_organizations_account.prod.id}"
}

output "prod_organization_account_access_role" {
  value = "arn:aws:iam::${aws_organizations_account.prod.id}:role/OrganizationAccountAccessRole"
}
