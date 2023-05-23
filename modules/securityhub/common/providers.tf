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

provider "awsutils" {
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
  source = "../../account-map/modules/iam-roles"

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
  alias  = "ssm"
  region = var.opsgenie_integration_uri_ssm_region

  assume_role {
    role_arn = local.opsgenie_integration_enabled ? module.securityhub_opsgenie_integration_ssm_role[0].terraform_role_arn : ""
  }
}

module "securityhub_opsgenie_integration_ssm_role" {
  count = local.enabled && local.opsgenie_integration_enabled ? 1 : 0

  source  = "../../account-map/modules/iam-roles"
  stage   = var.opsgenie_integration_uri_ssm_account
  context = module.this.context
}
