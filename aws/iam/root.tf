# Provision group access to root account with MFA
module "organization_access_group_root" {
  source           = "git::https://github.com/cloudposse/terraform-aws-iam-assumed-roles.git?ref=tags/0.2.0"
  namespace        = "${var.namespace}"
  stage            = "root"
  admin_name       = "admin"
  readonly_name    = "readonly"
  admin_user_names = ["erik", "andriy", "igor", "sarkis"]
}
