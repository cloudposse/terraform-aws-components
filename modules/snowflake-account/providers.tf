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

data "aws_ssm_parameter" "snowflake_password" {
  count           = local.enabled ? 1 : 0
  name            = local.ssm_path_admin_user_password
  with_decryption = true
}

provider "snowflake" {
  account  = var.snowflake_account
  region   = "${var.snowflake_account_region}.aws" # required to append ".aws" to region, see https://github.com/chanzuckerberg/terraform-provider-snowflake/issues/529
  username = local.admin_username
  password = data.aws_ssm_parameter.snowflake_password[0].value
}
