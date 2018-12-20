variable "corp_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Dev account"
  default     = []
}

# Provision group access to corp account
module "organization_access_group_corp" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  enabled           = "${contains(var.accounts_enabled, "corp") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "corp"
  name              = "admin"
  user_names        = "${var.corp_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.corp_account_id}"
  require_mfa       = "true"
}
