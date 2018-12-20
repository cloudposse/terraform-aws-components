variable "security_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `security` account"
  default     = []
}

# Provision group access to security account
module "organization_access_group_security" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  enabled           = "${contains(var.accounts_enabled, "security") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "security"
  name              = "admin"
  user_names        = "${var.security_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.security_account_id}"
  require_mfa       = "true"
}
