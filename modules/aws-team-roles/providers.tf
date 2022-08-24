provider "aws" {
  region = var.region

  # aws-team-roles, since it creates the initial "admin", "terraform", and other roles,
  # must be run as SuperAdmin, and cannot use "profile" instead of "role_arn"
  # even if the components are generally using profiles.
  # Note the role_arn is the ARN of the OrganizationAccountAccessRole, not the SAML role.

  dynamic "assume_role" {
    for_each = var.import_role_arn == null ? (module.iam_roles.org_role_arn != null ? [true] : []) : ["import"]
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_roles.org_role_arn)
    }
  }
}

module "iam_roles" {
  source     = "../account-map/modules/iam-roles"
  privileged = true
  context    = module.this.context
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
