variable "prod_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Production account"
  default     = []
}

# Provision group access to production account
module "organization_access_group_prod" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.2.1"
  namespace         = "${var.namespace}"
  stage             = "prod"
  name              = "admin"
  user_names        = "${var.prod_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.prod_account_id}"
  require_mfa       = "true"
}
