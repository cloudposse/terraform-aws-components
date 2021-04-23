variable "aws_profile_name" {
  type        = string
  default     = null
  description = <<-EOT
  Profile to use with the AWS Provider
  This can be used for importing locally which does not allow data sources
  EOT
}

variable "aws_role_arn" {
  type        = string
  default     = null
  description = <<-EOT
  Role ARN to assume with the AWS Provider
  This can be used for importing locally which does not allow data sources
  EOT
}

variable "iam_roles_profile_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
  Whether or not to use the account-map's iam-roles module to pull the AWS Profile
  Conflicts with `iam_roles_role_arn_enabled`
  EOT
}

variable "iam_roles_role_arn_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
  Whether or not to use the account-map's iam-roles module to pull the AWS Role ARN
  Conflicts with `iam_roles_profile_enabled`
  EOT
}

module "iam_roles" {
  count   = var.iam_roles_profile_enabled || var.iam_roles_role_arn_enabled ? 1 : 0
  source  = "cloudposse/components/aws//modules/account-map/modules/iam-roles"
  version = "0.146.0"
  context = module.this.context
}

locals {
  iam_roles_profile  = join("", module.iam_roles[*].terraform_profile_name)
  iam_roles_role_arn = join("", module.iam_roles[*].terraform_role_arn)

  profile = var.iam_roles_profile_enabled ? local.iam_roles_profile : var.aws_profile_name

  wrapped_role_arn = var.aws_role_arn != null ? [var.aws_role_arn] : []
  role_arn         = var.iam_roles_role_arn_enabled ? [local.iam_roles_role_arn] : local.wrapped_role_arn
}

provider "aws" {
  region  = var.region
  profile = local.profile

  dynamic "assume_role" {
    for_each = local.role_arn
    content {
      role_arn     = assume_role.value
      session_name = basename(path.root)
      external_id  = "terraform"
    }
  }
}
