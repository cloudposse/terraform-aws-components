# Assuming region-a is default.
# tgw_this_region is network of region-b
# tgw_home_region is network of region-a

provider "aws" {
  alias  = "tgw_this_region"
  region = var.region

  profile = module.iam_role_tgw_this_region.profiles_enabled ? coalesce(var.import_profile_name, module.iam_role_tgw_this_region.terraform_profile_name) : null
  dynamic "assume_role" {
    for_each = module.iam_role_tgw_this_region.profiles_enabled ? [] : ["role"]
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_role_tgw_this_region.terraform_role_arn)
    }
  }
}

provider "aws" {
  alias  = "tgw_home_region"
  region = var.home_region.region

  profile = module.iam_role_tgw_home_region.profiles_enabled ? coalesce(var.import_profile_name, module.iam_role_tgw_home_region.terraform_profile_name) : null
  dynamic "assume_role" {
    for_each = module.iam_role_tgw_home_region.profiles_enabled ? [] : ["role"]
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_role_tgw_home_region.terraform_role_arn)
    }
  }
}

module "iam_role_tgw_this_region" {
  source  = "../../account-map/modules/iam-roles"
  stage   = var.this_region.tgw_stage_name
  tenant  = var.this_region.tgw_tenant_name
  context = module.this.context
}

module "iam_role_tgw_home_region" {
  source      = "../../account-map/modules/iam-roles"
  stage       = var.home_region.tgw_stage_name
  tenant      = var.home_region.tgw_tenant_name
  environment = var.home_region.environment
  context     = module.this.context
}

module "iam_roles" {
  source             = "../../account-map/modules/iam-roles"
  global_tenant_name = var.account_map_tenant_name
  context            = module.this.context
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
