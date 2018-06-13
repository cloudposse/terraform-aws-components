variable "testing_account_id" {
  type        = "string"
  description = "Testing account ID"
}

variable "testing_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to Testing account"
}

# Provision group access to testing account
module "organization_access_group_testing" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.1.2"
  namespace         = "${var.namespace}"
  stage             = "testing"
  name              = "admin"
  user_names        = ["${var.testing_account_user_names}"]
  member_account_id = "${var.testing_account_id}"
}
