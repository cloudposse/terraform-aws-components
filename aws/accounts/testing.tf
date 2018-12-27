module "testing" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "testing"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "testing_account_arn" {
  value = "${module.testing.account_arn}"
}

output "testing_account_id" {
  value = "${module.testing.account_id}"
}

output "testing_organization_account_access_role" {
  value = "${module.testing.organization_account_access_role}"
}
