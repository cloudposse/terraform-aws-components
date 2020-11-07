variable "security_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `security` account"
  default     = []
}

# Provision group access to security account
module "organization_access_group_security" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.accounts_enabled, "security") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "security"
  name              = "admin"
  user_names        = "${var.security_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.security_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_security" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "security") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/security/admin_group"
      value       = "${module.organization_access_group_security.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'security' account"
    },
  ]
}

output "security_switchrole_url" {
  description = "URL to the IAM console to switch to the security account organization access role"
  value       = "${module.organization_access_group_security.switchrole_url}"
}
