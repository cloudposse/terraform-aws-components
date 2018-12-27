module "staging" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "staging"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "staging_account_arn" {
  value = "${module.staging.account_arn}"
}

output "staging_account_id" {
  value = "${module.staging.account_id}"
}

output "staging_organization_account_access_role" {
  value = "${module.staging.organization_account_access_role}"
}
