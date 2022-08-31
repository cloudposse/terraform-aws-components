provider "aws" {
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
  }
}

provider "awsutils" {
  region = var.region

  assume_role {
    role_arn = coalesce(var.import_role_arn, module.iam_roles.terraform_role_arn)
  }
}

module "iam_roles" {
  source  = "../account-map/modules/iam-roles"
  context = module.this.context
}

variable "import_role_arn" {
  type        = string
  default     = null
  description = "IAM Role ARN to use when importing a resource"
}
