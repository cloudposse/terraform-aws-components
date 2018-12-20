variable "staging_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Staging account"
  default     = []
}

# Provision group access to staging account
module "organization_access_group_staging" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  enabled           = "${contains(var.accounts_enabled, "staging") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "staging"
  name              = "admin"
  user_names        = "${var.staging_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.staging_account_id}"
  require_mfa       = "true"
}
