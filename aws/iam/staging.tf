variable "staging_account_id" {
  type        = "string"
  description = "Staging account ID"
}

variable "staging_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Staging account"
}

# Provision group access to staging account
module "organization_access_group_staging" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.1.3"
  namespace         = "${var.namespace}"
  stage             = "staging"
  name              = "admin"
  user_names        = ["${var.staging_account_user_names}"]
  member_account_id = "${local.staging_account_id}"
  require_mfa       = "true"
}
