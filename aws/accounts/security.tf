module "security" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "security"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "security_account_arn" {
  value = "${module.security.account_arn}"
}

output "security_account_id" {
  value = "${module.security.account_id}"
}

output "security_organization_account_access_role" {
  value = "${module.security.organization_account_access_role}"
}
