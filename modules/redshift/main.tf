locals {
  enabled            = module.this.enabled
  private_subnet_ids = module.vpc.outputs.private_subnet_ids
  admin_user         = var.admin_user != null && var.admin_user != "" ? var.admin_user : join("", random_pet.admin_user.*.id)
  admin_password     = var.admin_password != null && var.admin_password != "" ? var.admin_password : join("", random_password.admin_password.*.result)
}

resource "random_pet" "admin_user" {
  count = local.enabled && (var.admin_user == null || var.admin_user == "") ? 1 : 0

  length    = 2
  separator = "_"

  keepers = {
    db_name = var.database_name
  }
}

resource "random_password" "admin_password" {
  count = local.enabled && (var.admin_password == null || var.admin_password == "") ? 1 : 0

  length = 33
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"

  keepers = {
    db_name = var.database_name
  }
}

module "redshift_cluster" {
  source  = "cloudposse/redshift-cluster/aws"
  version = "1.0.0"

  cluster_identifier = var.cluster_identifier

  subnet_ids             = local.private_subnet_ids
  vpc_security_group_ids = [module.security_group.id]

  admin_user            = local.admin_user
  admin_password        = local.admin_password
  database_name         = var.database_name
  node_type             = var.node_type
  cluster_type          = var.cluster_type
  number_of_nodes       = var.number_of_nodes
  engine_version        = var.engine_version
  publicly_accessible   = var.publicly_accessible
  allow_version_upgrade = var.allow_version_upgrade

  context = module.this.context
}
