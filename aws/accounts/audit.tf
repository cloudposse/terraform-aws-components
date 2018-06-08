variable "audit_account_name" {
  type        = "string"
  description = "Audit account name"
  default     = "audit"
}

variable "audit_account_email" {
  type        = "string"
  description = "Audit account email"
}

resource "aws_organizations_account" "audit" {
  name                       = "${var.audit_account_name}"
  email                      = "${var.audit_account_email}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "audit_account_arn" {
  value = "${aws_organizations_account.audit.arn}"
}
