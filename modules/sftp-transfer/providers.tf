module "iam_roles" {
  source  = "../account-map/modules/iam-roles"
  context = module.this.context
}

provider "aws" {
  region = var.region

  assume_role {
    role_arn = module.iam_roles.terraform_role_arn
  }
}
