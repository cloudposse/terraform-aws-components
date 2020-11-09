module "full_access" {
  source = "../account-map/modules/roles-to-principals"

  role_map = var.read_write_account_role_map
  region   = var.region
}

module "readonly_access" {
  source = "../account-map/modules/roles-to-principals"

  role_map = var.read_only_account_role_map
  region   = var.region
}

locals {
  ecr_writers = flatten([for w in var.cicd_accounts : data.terraform_remote_state.eks-iam[w].outputs.cicd_roles])
}

module "ecr" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=tags/0.29.0"

  image_names                = var.images
  max_image_count            = var.max_image_count
  principals_full_access     = compact(concat(module.full_access.principals, local.ecr_writers))
  principals_readonly_access = module.readonly_access.principals
  use_fullname               = false

  context = module.this.context
}
