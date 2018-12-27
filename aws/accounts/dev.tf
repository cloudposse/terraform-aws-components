module "dev" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "dev"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "dev_account_arn" {
  value = "${module.dev.account_arn}"
}

output "dev_account_id" {
  value = "${module.dev.account_id}"
}

output "dev_organization_account_access_role" {
  value = "${module.dev.organization_account_access_role}"
}
