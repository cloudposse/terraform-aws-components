provider "aws" {
  region = var.region

  profile = module.iam_roles.profiles_enabled ? coalesce(var.import_profile_name, module.iam_roles.terraform_profile_name) : null
  dynamic "assume_role" {
    for_each = module.iam_roles.profiles_enabled ? [] : ["role"]
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
    }
  }
}

variable "terraform_user" {
  type        = string
  description = <<-EOT
    The user (role) name of the entity performing Terraform operations.
    Required only when special access is needed (typically Spacelift or CI/CD).
    EOT
  default     = null
}

module "iam_roles" {
  source         = "../account-map/modules/iam-roles"
  terraform_user = var.terraform_user
  context        = module.this.context
}

variable "import_profile_name" {
  type        = string
  default     = null
  description = "AWS Profile name to use when importing a resource"
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
