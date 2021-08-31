module "cluster" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = [var.cluster_name]

  context = module.this.context
}

# https://www.terraform.io/docs/providers/aws/r/rds_global_cluster.html
resource "aws_rds_global_cluster" "default" {
  count = local.enabled ? 1 : 0

  global_cluster_identifier = module.cluster.id
  database_name             = var.db_name
  deletion_protection       = var.deletion_protection
  engine                    = var.engine
  engine_version            = var.engine_version
  storage_encrypted         = var.storage_encrypted
}

# Really should use random_pet, but we have already deployed
# random_string and changing the name requires recreating the cluster
resource "random_pet" "admin_user" {
  count = local.enabled && length(var.admin_user) == 0 ? 1 : 0

  # word length
  length = 5

  separator = ""

  keepers = {
    cluster_name = var.cluster_name
    db_name      = var.db_name
  }
}

resource "random_password" "admin_password" {
  count  = local.enabled && length(var.admin_password) == 0 ? 1 : 0
  length = 33
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"

  keepers = {
    cluster_name = var.cluster_name
    db_name      = var.db_name
  }
}

locals {
  enabled = module.this.enabled

  primary_vpc_id             = module.vpc_primary.outputs.vpc_id
  primary_private_subnet_ids = module.vpc_primary.outputs.private_subnet_ids

  existing_security_groups = var.use_eks_security_group ? [module.eks[0].outputs.eks_cluster_managed_security_group_id] : []
  zone_id                  = module.dns_gbl_delegated.outputs.default_dns_zone_id

  admin_user     = length(var.admin_user) > 0 ? var.admin_user : substr(join("", random_pet.admin_user.*.id), 0, 16)
  admin_password = length(var.admin_password) > 0 ? var.admin_password : join("", random_password.admin_password.*.result)
  database_name  = var.db_name

  cluster_dns_name_prefix  = format("%v%v%v%v", module.this.name, module.this.delimiter, var.cluster_name, module.this.delimiter)
  primary_cluster_dns_name = format("%v%v", local.cluster_dns_name_prefix, var.primary_cluster_dns_name_part)
  primary_reader_dns_name  = format("%v%v", local.cluster_dns_name_prefix, var.primary_reader_dns_name_part)

  ssm_key_prefix = format("/%v/%v", var.ssm_path_prefix, module.cluster.id)
}
