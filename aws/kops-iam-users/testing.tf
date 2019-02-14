module "kops_admin_access_group_testing" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "testing") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "testing"
  name              = "admin"
  attributes        = ["kops"]
  role_name         = "${module.kops_admin_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.testing_account_id}"
  require_mfa       = "true"
}

module "kops_readonly_access_group_testing" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.kops_iam_accounts_enabled, "testing") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "testing"
  name              = "readonly"
  attributes        = ["kops"]
  role_name         = "${module.kops_readonly_label.id}"
  user_names        = []
  member_account_id = "${data.terraform_remote_state.accounts.testing_account_id}"
  require_mfa       = "true"
}
