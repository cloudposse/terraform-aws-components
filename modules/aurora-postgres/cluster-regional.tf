# A child module automatically inherits default (un-aliased) provider configurations from its parent.
# This means that explicit provider blocks appear only in the root module, and downstream modules can simply
# declare resources for that provider and have them automatically associated with the root provider configurations

locals {
  additional_users           = local.enabled ? var.additional_users : {}
  sanitized_additional_users = { for k, v in module.additional_users : k => { for kk, vv in v : kk => vv if kk != "db_user_password" } }
}

# https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
module "aurora_postgres_cluster" {
  source  = "cloudposse/rds-cluster/aws"
  version = "0.47.2"

  cluster_type   = "regional"
  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode
  cluster_family = var.cluster_family
  instance_type  = var.instance_type
  cluster_size   = var.cluster_size
  admin_user     = local.admin_user
  admin_password = local.admin_password

  db_name                             = local.database_name
  publicly_accessible                 = var.publicly_accessible
  db_port                             = var.database_port
  vpc_id                              = local.vpc_id
  subnets                             = local.private_subnet_ids
  zone_id                             = local.zone_id
  cluster_dns_name                    = local.cluster_dns_name
  reader_dns_name                     = local.reader_dns_name
  security_groups                     = local.allowed_security_groups
  allowed_cidr_blocks                 = concat(var.allowed_cidr_blocks, [module.vpc_spacelift.outputs.vpc_cidr])
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted                   = var.storage_encrypted
  kms_key_arn                         = var.storage_encrypted ? module.kms_key_rds.key_arn : null
  performance_insights_kms_key_id     = var.performance_insights_enabled ? module.kms_key_rds.key_arn : null
  maintenance_window                  = var.maintenance_window
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  enhanced_monitoring_role_enabled    = var.enhanced_monitoring_role_enabled
  performance_insights_enabled        = var.performance_insights_enabled
  rds_monitoring_interval             = var.rds_monitoring_interval
  autoscaling_enabled                 = var.autoscaling_enabled
  autoscaling_policy_type             = var.autoscaling_policy_type
  autoscaling_target_metrics          = var.autoscaling_target_metrics
  autoscaling_target_value            = var.autoscaling_target_value
  autoscaling_scale_in_cooldown       = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown      = var.autoscaling_scale_out_cooldown
  autoscaling_min_capacity            = var.autoscaling_min_capacity
  autoscaling_max_capacity            = var.autoscaling_max_capacity
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  snapshot_identifier                 = var.snapshot_identifier

  cluster_parameters = [
    {
      apply_method = "immediate"
      name         = "log_statement"
      value        = "all"
    },
    {
      apply_method = "immediate"
      name         = "log_min_duration_statement"
      value        = "0"
    }
  ]

  context = module.cluster.context
}

resource "postgresql_database" "additional" {
  for_each   = module.this.enabled ? var.additional_databases : []
  name       = each.key
  depends_on = [module.aurora_postgres_cluster.cluster_identifier]
}

module "additional_users" {
  for_each = local.additional_users
  source   = "./modules/postgresql-user"

  service_name    = each.key
  db_user         = each.value.db_user
  db_password     = each.value.db_password
  grants          = each.value.grants
  ssm_path_prefix = local.ssm_path_prefix

  depends_on = [module.aurora_postgres_cluster.cluster_identifier]
}
