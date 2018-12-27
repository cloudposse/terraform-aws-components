module "prod" {
  source                             = "stage"
  namespace                          = "${var.namespace}"
  stage                              = "prod"
  accounts_enabled                   = "${var.accounts_enabled}"
  account_email                      = "${var.account_email}"
  account_iam_user_access_to_billing = "${var.account_iam_user_access_to_billing}"
  account_role_name                  = "${var.account_role_name}"
}

output "prod_account_arn" {
  value = "${module.prod.account_arn}"
}

output "prod_account_id" {
  value = "${module.prod.account_id}"
}

output "prod_organization_account_access_role" {
  value = "${module.prod.organization_account_access_role}"
}
