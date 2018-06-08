variable "prod_account_name" {
  type        = "string"
  description = "Prod account name"
  default     = "prod"
}

variable "prod_account_email" {
  type        = "string"
  description = "Prod account email"
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
