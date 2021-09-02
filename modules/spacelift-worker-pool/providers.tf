provider "spacelift" {
  api_key_endpoint = var.spacelift_api_endpoint
  api_key_id       = data.aws_ssm_parameter.spacelift_key_id.value
  api_key_secret   = data.aws_ssm_parameter.spacelift_key_secret.value
}

data "aws_ssm_parameter" "spacelift_key_id" {
  name = "/spacelift/key_id"
}

data "aws_ssm_parameter" "spacelift_key_secret" {
  name = "/spacelift/key_secret"
}

provider "aws" {
  region = var.region
  # `terraform import` will not use data from a data source,
  # so on import we have to explicitly specify the profile
  profile = coalesce(var.import_profile_name, module.iam_roles.terraform_profile_name)
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
