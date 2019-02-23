variable "audit_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `audit` account"
  default     = []
}

# Provision group access to audit account. Careful! Very few people, if any should have access to this account.
module "organization_access_group_audit" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.accounts_enabled, "audit") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "audit"
  name              = "admin"
  user_names        = "${var.audit_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.audit_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_audit" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "audit") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/audit/admin_group"
      value       = "${module.organization_access_group_audit.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'audit' account"
    },
  ]
}

output "audit_switchrole_url" {
  description = "URL to the IAM console to switch to the audit account organization access role"
  value       = "${module.organization_access_group_audit.switchrole_url}"
}
