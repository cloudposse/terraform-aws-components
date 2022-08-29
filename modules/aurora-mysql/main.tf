locals {
  enabled = module.this.enabled

  vpc_outputs                           = module.vpc.outputs
  dns_delegated_outputs                 = module.dns-delegated.outputs
  eks_outputs                           = module.eks.outputs
  vpc_id                                = local.vpc_outputs.vpc_id
  public_subnet_ids                     = local.vpc_outputs.public_subnet_ids
  private_subnet_ids                    = local.vpc_outputs.private_subnet_ids
  zone_id                               = local.dns_delegated_outputs.default_dns_zone_id
  eks_cluster_managed_security_group_id = local.eks_outputs.eks_cluster_managed_security_group_id

  cluster_domain = local.mysql_enabled ? trimprefix(module.aurora_mysql.endpoint, "${module.aurora_mysql.cluster_identifier}.cluster-") : null


  mysql_enabled        = var.mysql_cluster_enabled && local.enabled
  mysql_admin_user     = length(var.mysql_admin_user) > 0 ? var.mysql_admin_user : join("", random_pet.mysql_admin_user.*.id)
  fetch_admin_password = local.enabled && length(var.ssm_password_source) > 0
  mysql_admin_password = local.fetch_admin_password ? data.aws_ssm_parameter.password[0].value : (
    length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : join("", random_password.mysql_admin_password.*.result)
  )
  mysql_admin_password_key = format("/%s/admin/%s/%s", var.ssm_path_prefix, "aurora-mysql", "password")

  mysql_db_name = length(var.mysql_db_name) > 0 ? var.mysql_db_name : join("", random_pet.mysql_db_name.*.id)

  cluster_subdomain = var.mysql_name == "" ? module.this.name : "${var.mysql_name}.${module.this.name}"

  ssm_path_prefix        = format("/%s/%s", var.ssm_path_prefix, module.cluster.id)
  ssm_cluster_key_prefix = format("%s/%s", local.ssm_path_prefix, "cluster")
}

module "cluster" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = [var.mysql_name]

  context = module.this.context
}

resource "random_pet" "mysql_admin_user" {
  count     = local.mysql_enabled && length(var.mysql_admin_user) == 0 ? 1 : 0
  length    = 2
  separator = "_"
}

resource "random_password" "mysql_admin_password" {
  count   = local.mysql_enabled && length(var.mysql_admin_password) == 0 && local.fetch_admin_password == false ? 1 : 0
  length  = 33
  special = false
}

resource "random_pet" "mysql_db_name" {
  count = local.mysql_enabled && length(var.mysql_db_name) == 0 ? 1 : 0

  separator = "_"

  keepers = {
    cluster_name = var.mysql_name
    db_name      = var.mysql_db_name
  }
}


