variable "data_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Dev account"
  default     = []
}

# Provision group access to data account
module "organization_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  enabled           = "${contains(var.accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "admin"
  user_names        = "${var.data_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}
