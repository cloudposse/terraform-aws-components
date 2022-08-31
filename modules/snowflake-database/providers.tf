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
  source  = "../account-map/modules/iam-roles"
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

data "aws_ssm_parameter" "snowflake_username" {
  count = local.enabled ? 1 : 0
  name  = module.snowflake_account.outputs.ssm_path_terraform_user_name
}

data "aws_ssm_parameter" "snowflake_private_key" {
  count           = local.enabled ? 1 : 0
  name            = module.snowflake_account.outputs.ssm_path_terraform_user_private_key
  with_decryption = true
}

provider "snowflake" {
  account = local.snowflake_account
  # required to append ".aws" to region, see https://github.com/chanzuckerberg/terraform-provider-snowflake/issues/529
  region      = "${local.snowflake_account_region}.aws"
  username    = data.aws_ssm_parameter.snowflake_username[0].value
  private_key = data.aws_ssm_parameter.snowflake_private_key[0].value
}
