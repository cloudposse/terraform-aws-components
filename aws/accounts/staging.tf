variable "staging_account_name" {
  type        = "string"
  description = "Staging account name"
  default     = "staging"
}

variable "staging_account_email" {
  type        = "string"
  description = "Staging account email"
}

resource "aws_organizations_account" "staging" {
  name                       = "${var.staging_account_name}"
  email                      = "${var.staging_account_email}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "staging_account_arn" {
  value = "${aws_organizations_account.staging.arn}"
}

output "staging_account_id" {
  value = "${aws_organizations_account.staging.id}"
}

output "staging_organization_account_access_role" {
  value = "arn:aws:iam::${aws_organizations_account.staging.id}:role/OrganizationAccountAccessRole"
}
