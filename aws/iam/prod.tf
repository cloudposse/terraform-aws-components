variable "prod_account_id" {
  type        = "string"
  description = "Production account ID"
}

variable "prod_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Production account"
}

# Provision group access to production account
module "organization_access_group_prod" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.1.3"
  namespace         = "${var.namespace}"
  stage             = "prod"
  name              = "admin"
  user_names        = ["${var.prod_account_user_names}"]
  member_account_id = "${local.prod_account_id}"
  require_mfa       = "true"
}
