module "identity" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "identity"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "identity_account_arn" {
  value = "${module.identity.account_arn}"
}

output "identity_account_id" {
  value = "${module.identity.account_id}"
}

output "identity_organization_account_access_role" {
  value = "${module.identity.organization_account_access_role}"
}
