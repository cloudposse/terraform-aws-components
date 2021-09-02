module "kops_admin_data_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "kops"
  stage      = "data"
  attributes = ["admin"]
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "true"
}

module "kops_readonly_data_label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "kops"
  stage      = "data"
  attributes = ["readonly"]
  delimiter  = "${var.delimiter}"
  tags       = "${var.tags}"
  enabled    = "true"
}

module "kops_admin_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "kops"
  attributes        = ["admin"]
  role_name         = "${module.kops_admin_data_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}

module "kops_readonly_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "kops"
  attributes        = ["readonly"]
  role_name         = "${module.kops_readonly_data_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}
