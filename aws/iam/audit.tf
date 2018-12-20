variable "audit_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Audit account"
  default     = []
}

# Provision group access to audit account. Careful! Very few people, if any should have access to this account.
module "organization_access_group_audit" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  namespace         = "${var.namespace}"
  stage             = "audit"
  name              = "admin"
  user_names        = "${var.audit_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.audit_account_id}"
  require_mfa       = "true"
}
