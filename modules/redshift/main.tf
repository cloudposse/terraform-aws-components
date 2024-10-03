locals {
  enabled        = module.this.enabled
  subnet_ids     = var.use_private_subnets ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
  admin_user     = var.admin_user != null && var.admin_user != "" ? var.admin_user : join("", random_pet.admin_user.*.id)
  admin_password = var.admin_password != null && var.admin_password != "" ? var.admin_password : join("", random_password.admin_password.*.result)
  database_name  = var.database_name == null ? module.this.id : var.database_name
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

  subnet_ids             = local.subnet_ids
  vpc_security_group_ids = coalesce(var.security_group_ids, module.redshift_sg[*].id, [])

  port                  = var.port
  admin_user            = local.admin_user
  admin_password        = local.admin_password
  database_name         = local.database_name
  node_type             = var.node_type
  number_of_nodes       = var.number_of_nodes
  cluster_type          = var.cluster_type
  engine_version        = var.engine_version
  publicly_accessible   = var.publicly_accessible
  allow_version_upgrade = var.allow_version_upgrade

  context = module.this.context
}

module "redshift_sg" {
  count = local.enabled && var.custom_sg_enabled ? 1 : 0

  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  create_before_destroy      = true
  preserve_security_group_id = true

  attributes = ["redshift"]

  # Allow unlimited egress
  allow_all_egress = var.custom_sg_allow_all_egress

  rules = var.custom_sg_rules

  vpc_id = module.vpc.outputs.vpc_id

  context = module.this.context
}
