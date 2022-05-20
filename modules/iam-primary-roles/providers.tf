provider "aws" {
  region = var.region

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
  description = "IAM Role ARN to use when importing a resource"
  default     = null
}
