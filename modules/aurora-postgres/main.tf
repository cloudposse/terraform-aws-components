locals {
  enabled = module.this.enabled

  vpc_id                  = module.vpc.outputs.vpc_id
  private_subnet_ids      = module.vpc.outputs.private_subnet_ids
  allowed_security_groups = [module.eks.outputs.eks_cluster_managed_security_group_id]

  zone_id = module.dns_gbl_delegated.outputs.default_dns_zone_id

  admin_user     = length(var.admin_user) > 0 ? var.admin_user : join("", random_pet.admin_user.*.id)
  admin_password = length(var.admin_password) > 0 ? var.admin_password : join("", random_password.admin_password.*.result)
  database_name  = length(var.database_name) > 0 ? var.database_name : join("", random_pet.database_name.*.id)

  cluster_dns_name_prefix = format("%v%v%v%v", module.this.name, module.this.delimiter, var.cluster_name, module.this.delimiter)
  cluster_dns_name        = format("%v%v", local.cluster_dns_name_prefix, var.cluster_dns_name_part)
  reader_dns_name         = format("%v%v", local.cluster_dns_name_prefix, var.reader_dns_name_part)

  ssm_path_prefix        = format("/%s/%s", var.ssm_path_prefix, module.cluster.id)
  ssm_cluster_key_prefix = format("%s/%s", local.ssm_path_prefix, "cluster")
}

module "cluster" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = [var.cluster_name]

  context = module.this.context
}

resource "random_pet" "database_name" {
  count = local.enabled && length(var.database_name) == 0 ? 1 : 0

  separator = "_"

  keepers = {
    cluster_name = var.cluster_name
    db_name      = var.database_name
  }
}

resource "random_pet" "admin_user" {
  count = local.enabled && length(var.admin_user) == 0 ? 1 : 0

  length    = 2
  separator = "_"

  keepers = {
    cluster_name = var.cluster_name
    db_name      = var.database_name
  }
}

resource "random_password" "admin_password" {
  count = local.enabled && length(var.admin_password) == 0 ? 1 : 0

  length = 33
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"

  keepers = {
    cluster_name = var.cluster_name
    db_name      = var.database_name
  }
}
