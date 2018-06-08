variable "prod_account_id" {
  type        = "string"
  description = "Prod account ID"
}

# Provision group access to production account
module "organization_access_group_prod" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.1.2"
  namespace         = "${var.namespace}"
  stage             = "prod"
  name              = "admin"
  user_names        = ["erik", "andriy", "igor", "sarkis"]
  member_account_id = "${var.prod_account_id}"
}
