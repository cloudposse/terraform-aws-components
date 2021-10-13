variable "root_account_admin_user_names" {
  type        = "list"
  description = "IAM user names to grant admin access to Root account"
  default     = []
}

variable "root_account_readonly_user_names" {
  type        = "list"
  description = "IAM user names to grant readonly access to Root account"
  default     = []
}

# Provision group access to root account with MFA
module "organization_access_group_root" {
  source              = "git::https://github.com/cloudposse/terraform-aws-iam-assumed-roles.git?ref=tags/0.6.0"
  namespace           = "${var.namespace}"
  stage               = "root"
  admin_name          = "admin"
  readonly_name       = "readonly"
  admin_user_names    = ["${var.root_account_admin_user_names}"]
  readonly_user_names = ["${var.root_account_readonly_user_names}"]
}

module "organization_access_group_ssm_root" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"

  parameter_write = [
    {
      name        = "/${var.namespace}/${var.stage}/admin_group"
      value       = "${module.organization_access_group_root.group_admin_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the '${var.stage}' account"
    },
    {
      name        = "/${var.namespace}/${var.stage}/readonly_group"
      value       = "${module.organization_access_group_root.group_readonly_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM readonly group name for the '${var.stage}' account"
    },
  ]
}

output "admin_group" {
  value = "${module.organization_access_group_root.group_admin_name}"
}

output "admin_switchrole_url" {
  description = "URL to the IAM console to switch to the admin role"
  value       = "${module.organization_access_group_root.switchrole_admin_url}"
}

output "readonly_group" {
  value = "${module.organization_access_group_root.group_readonly_name}"
}

output "readonly_switchrole_url" {
  description = "URL to the IAM console to switch to the readonly role"
  value       = "${module.organization_access_group_root.switchrole_readonly_url}"
}
