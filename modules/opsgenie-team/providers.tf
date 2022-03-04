provider "aws" {
  region = var.region

  assume_role {
    # `terraform import` will not use data from a data source,
    # so on import we have to explicitly specify the role
    role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
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

data "aws_ssm_parameter" "opsgenie_api_key" {
  name            = format(var.ssm_parameter_name_format, var.ssm_path, "opsgenie_api_key")
  with_decryption = true
}

provider "opsgenie" {
  api_key = data.aws_ssm_parameter.opsgenie_api_key.value
}

