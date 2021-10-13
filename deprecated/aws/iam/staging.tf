variable "staging_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `staging` account"
  default     = []
}

# Provision group access to staging account
module "organization_access_group_staging" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.accounts_enabled, "staging") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "staging"
  name              = "admin"
  user_names        = "${var.staging_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.staging_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_staging" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "staging") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/staging/admin_group"
      value       = "${module.organization_access_group_staging.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'staging' account"
    },
  ]
}

output "staging_switchrole_url" {
  description = "URL to the IAM console to switch to the staging account organization access role"
  value       = "${module.organization_access_group_staging.switchrole_url}"
}
