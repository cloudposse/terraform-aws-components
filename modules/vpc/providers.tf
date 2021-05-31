provider "aws" {
  region = var.region

  # `terraform import` will not use data from a data source, so on import we have to explicitly specify the profile
  # profile = coalesce(var.import_profile_name, module.iam_roles.terraform_profile_name)

  assume_role {
    role_arn = "arn:aws:iam::101236733906:role/atmos-gbl-root-terraform"
  }
}

output "debug-iam_roles" {
  value = module.iam_roles
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

# provider "aws" {
#   region = var.region

#   assume_role {
#     role_arn = var.aws_assume_role_arn
#   }
# }

# variable "aws_assume_role_arn" {
#   type        = string
#   description = "ARN of the IAM role to assume to access the AWS account where the infrastructure is provisioned"
# }
