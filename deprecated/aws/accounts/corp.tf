module "corp" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "corp"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "corp_account_arn" {
  value = "${module.corp.account_arn}"
}

output "corp_account_id" {
  value = "${module.corp.account_id}"
}

output "corp_organization_account_access_role" {
  value = "${module.corp.organization_account_access_role}"
}
