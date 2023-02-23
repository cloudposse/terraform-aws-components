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

provider "aws" {
  alias   = "config_secrets"
  region  = var.ssm_store_account_region
  profile = coalesce(var.import_profile_name, module.iam_roles_config_secrets.terraform_profile_name)
}

module "iam_roles_config_secrets" {
  source  = "../../account-map/modules/iam-roles"
  stage   = var.ssm_store_account
  tenant  = var.ssm_store_account_tenant
  context = module.this.context
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
