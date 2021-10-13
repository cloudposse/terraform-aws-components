module "audit" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "audit"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "audit_account_arn" {
  value = "${module.audit.account_arn}"
}

output "audit_account_id" {
  value = "${module.audit.account_id}"
}

output "audit_organization_account_access_role" {
  value = "${module.audit.organization_account_access_role}"
}
