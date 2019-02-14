module "kops_admin_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "admin"
  attributes        = ["kops"]
  role_name         = "${module.kops_admin_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}

module "kops_readonly_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "readonly"
  attributes        = ["kops"]
  role_name         = "${module.kops_readonly_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}
