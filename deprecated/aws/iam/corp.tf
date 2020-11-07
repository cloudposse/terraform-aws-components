variable "corp_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `corp` account"
  default     = []
}

# Provision group access to corp account
module "organization_access_group_corp" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.accounts_enabled, "corp") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "corp"
  name              = "admin"
  user_names        = "${var.corp_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.corp_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_corp" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "corp") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/corp/admin_group"
      value       = "${module.organization_access_group_corp.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'corp' account"
    },
  ]
}

output "corp_switchrole_url" {
  description = "URL to the IAM console to switch to the corp account organization access role"
  value       = "${module.organization_access_group_corp.switchrole_url}"
}
