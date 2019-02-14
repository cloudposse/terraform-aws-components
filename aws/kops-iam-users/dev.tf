module "kops_admin_access_group_dev" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "dev") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "dev"
  name              = "admin"
  attributes        = ["kops"]
  role_name         = "${module.kops_admin_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.dev_account_id}"
  require_mfa       = "true"
}

module "kops_readonly_access_group_dev" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "dev") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "dev"
  name              = "readonly"
  attributes        = ["kops"]
  role_name         = "${module.kops_readonly_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.dev_account_id}"
  require_mfa       = "true"
}
