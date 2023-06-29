provider "aws" {
  alias  = "tgw-hub"
  region = var.region

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.tgw_hub_role.terraform_profile_name

  dynamic "assume_role" {
    # module.tgw_hub_role.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.tgw_hub_role.terraform_role_arn])
    content {
      role_arn = assume_role.value
    }
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
