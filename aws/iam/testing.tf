variable "testing_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `testing` account"
  default     = []
}

# Provision group access to testing account
module "organization_access_group_testing" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  enabled           = "${contains(var.accounts_enabled, "testing") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "testing"
  name              = "admin"
  user_names        = "${var.testing_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.testing_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_testing" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "testing") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/testing/admin_group"
      value       = "${module.organization_access_group_testing.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'testing' account"
    },
  ]
}
