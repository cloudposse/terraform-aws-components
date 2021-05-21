provider "aws" {
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
  }
}

module "iam_roles" {
  source  = "../account-map/modules/iam-roles"
  context = module.this.context

  tfstate_assume_role             = var.tfstate_assume_role
  tfstate_existing_role_arn       = var.tfstate_existing_role_arn
  tfstate_account_id              = var.tfstate_account_id
  tfstate_role_arn_template       = var.tfstate_role_arn_template
  tfstate_role_environment_name   = var.tfstate_role_environment_name
  tfstate_role_stage_name         = var.tfstate_role_stage_name
  tfstate_bucket_environment_name = var.tfstate_bucket_environment_name
  tfstate_bucket_stage_name       = var.tfstate_bucket_stage_name
  tfstate_role_name               = var.tfstate_role_name
  tfstate_region                  = var.tfstate_region
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
