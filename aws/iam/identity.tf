variable "identity_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `identity` account"
  default     = []
}

# Provision group access to identity account
module "organization_access_group_identity" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  enabled           = "${contains(var.accounts_enabled, "identity") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "identity"
  name              = "admin"
  user_names        = "${var.identity_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.identity_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_identity" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "identity") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/identity/admin_group"
      value       = "${module.organization_access_group_identity.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'identity' account"
    },
  ]
}
