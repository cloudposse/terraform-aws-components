provider "aws" {
  region = var.region

  dynamic "assume_role" {
    for_each = module.iam_roles.org_role_arn != null ? [true] : []
    content {
      role_arn = coalesce(var.import_role_arn, module.iam_roles.org_role_arn)
    }
  }
}

module "iam_roles" {
  source                          = "../account-map/modules/iam-roles"
  namespace                       = module.this.namespace
  environment                     = module.this.environment
  stage                           = module.this.stage
  name                            = module.this.name
  region                          = var.region
  tfstate_assume_role             = false
  tfstate_existing_role_arn       = var.tfstate_existing_role_arn
  tfstate_account_id              = var.tfstate_account_id
  tfstate_role_arn_template       = var.tfstate_role_arn_template
  tfstate_role_environment_name   = var.tfstate_role_environment_name
  tfstate_role_stage_name         = var.tfstate_role_stage_name
  tfstate_bucket_environment_name = var.tfstate_bucket_environment_name
  tfstate_bucket_stage_name       = var.tfstate_bucket_stage_name
  tfstate_role_name               = var.tfstate_role_name
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
