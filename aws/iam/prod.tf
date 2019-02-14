variable "prod_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `prod` account"
  default     = []
}

# Provision group access to production account
module "organization_access_group_prod" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.4.0"
  enabled           = "${contains(var.accounts_enabled, "prod") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "prod"
  name              = "admin"
  user_names        = "${var.prod_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.prod_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_prod" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "prod") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/prod/admin_group"
      value       = "${module.organization_access_group_prod.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'prod' account"
    },
  ]
}

output "prod_switchrole_url" {
  description = "URL to the IAM console to switch to the prod account organization access role"
  value       = "${module.organization_access_group_prod.switchrole_url}"
}
