provider "aws" {
  region = var.region

  # `terraform import` will not use data from a data source, so on import we have to explicitly specify the profile
  profile = coalesce(var.import_profile_name, module.iam_roles.terraform_profile_name)
}

provider "aws" {
  alias  = "secondary"
  region = var.region_secondary

  # `terraform import` will not use data from a data source, so on import we have to explicitly specify the profile
  profile = coalesce(var.import_profile_name, module.iam_roles.terraform_profile_name)
}

module "iam_roles" {
  source  = "../account-map/modules/iam-roles"
  context = module.cluster.context
}

variable "import_profile_name" {
  type        = string
  default     = null
  description = "IAM Profile to use when importing a resource"
}

provider "aws" {
  alias  = "sdm_api_keys"
  region = var.sdm_ssm_region

  # `terraform import` will not use data from a data source, so on import we have to explicitly specify the profile
  profile = coalesce(var.import_profile_name, module.iam_roles_network.terraform_profile_name)
}

provider "postgresql" {
  host      = local.enabled ? time_sleep.db_cluster_propagation[0].triggers["master_host"] : null
  username  = local.enabled ? time_sleep.db_cluster_propagation[0].triggers["master_username"] : null
  password  = local.enabled ? time_sleep.db_cluster_propagation[0].triggers["admin_password"] : null
  superuser = false
}

module "iam_roles_network" {
  source  = "../account-map/modules/iam-roles"
  stage   = var.sdm_ssm_account
  context = module.this.context
}

provider "sdm" {
  api_access_key = local.sdm_enabled ? data.aws_ssm_parameter.api_access_key[0].value : null
  api_secret_key = local.sdm_enabled ? data.aws_ssm_parameter.api_secret_key[0].value : null
}
