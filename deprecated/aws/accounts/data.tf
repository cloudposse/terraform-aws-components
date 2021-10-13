module "data" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "data"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "data_account_arn" {
  value = "${module.data.account_arn}"
}

output "data_account_id" {
  value = "${module.data.account_id}"
}

output "data_organization_account_access_role" {
  value = "${module.data.organization_account_access_role}"
}
