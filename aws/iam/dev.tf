variable "dev_account_id" {
  type        = "string"
  description = "Dev account ID"
}

# Provision group access to dev account
module "organization_access_group_dev" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.1.2"
  namespace         = "${var.namespace}"
  stage             = "dev"
  name              = "admin"
  user_names        = ["erik", "andriy", "igor", "sarkis"]
  member_account_id = "${var.dev_account_id}"
}
