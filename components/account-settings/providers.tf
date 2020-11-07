provider "aws" {
  region = var.region

  dynamic "assume_role" {
    for_each = module.iam_roles.org_role_arn != null ? [true] : []
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_roles.org_role_arn)
    }
  }
}

module "iam_roles" {
  source              = "../account-map/modules/iam-roles"
  stage               = module.this.stage
  region              = var.region
  tfstate_assume_role = false
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
