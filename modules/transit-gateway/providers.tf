provider "aws" {
  alias  = "tgw"
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles_tgw.terraform_role_arn)
  }
}

module "iam_roles" {
  source   = "../account-map/modules/iam-roles"
  for_each = var.accounts_with_vpc
  stage    = each.value
  region   = var.region
}

module "iam_roles_tgw" {
  source = "../account-map/modules/iam-roles"
  stage  = var.tgw_stage_name
  region = var.region
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
