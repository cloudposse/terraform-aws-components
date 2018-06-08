variable "testing_account_name" {
  type        = "string"
  description = "Testing account name"
  default     = "testing"
}

variable "testing_account_email" {
  type        = "string"
  description = "Testing account email"
}

resource "aws_organizations_account" "testing" {
  name                       = "${var.testing_account_name}"
  email                      = "${var.testing_account_email}"
  iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  role_name                  = "${var.account_role_name}"
}

output "testing_account_arn" {
  value = "${aws_organizations_account.testing.arn}"
}
