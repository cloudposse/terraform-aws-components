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

module "iam_roles" {
  source  = "../../account-map/modules/iam-roles"
  context = module.this.context
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

provider "aws" {
  alias  = "tgw-hub"
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.tgw_hub_role.terraform_role_arn)
  }
}

variable "tgw_hub_environment_name" {
  type        = string
  description = "The name of the environment where `tgw/gateway` is provisioned"
  default     = "ue2"
}

variable "tgw_hub_stage_name" {
  type        = string
  description = "The name of the stage where `tgw/gateway` is provisioned"
  default     = "network"
}

variable "tgw_hub_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `tgw/hub` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

module "tgw_hub_role" {
  source = "../../account-map/modules/iam-roles"

  stage       = var.tgw_hub_stage_name
  environment = var.tgw_hub_environment_name
  tenant      = var.tgw_hub_tenant_name

  context = module.this.context
}
