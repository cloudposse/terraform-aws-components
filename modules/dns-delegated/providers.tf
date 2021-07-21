provider "aws" {
  # The AWS provider to use to make changes in the DNS primary account
  alias  = "primary"
  region = var.region

  # `terraform import` will not use data from a data source, so on import we have to explicitly specify the profile
  profile = coalesce(var.import_profile_name, module.iam_roles.dns_terraform_profile_name)
}

provider "aws" {
  # The AWS provider to use to make changes in the target (delegated) account
  alias  = "delegated"
  region = var.region

  # `terraform import` will not use data from a data source, so on import we have to explicitly specify the profile
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
