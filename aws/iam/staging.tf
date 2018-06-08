variable "staging_account_id" {
  type        = "string"
  description = "Staging account ID"
}

# Provision group access to staging account
module "organization_access_group_staging" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.1.2"
  namespace         = "${var.namespace}"
  stage             = "staging"
  name              = "admin"
  user_names        = ["erik", "andriy", "igor", "sarkis"]
  member_account_id = "${var.staging_account_id}"
}
