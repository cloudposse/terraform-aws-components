# A child module automatically inherits default (un-aliased) provider configurations from its parent.
# This means that explicit provider blocks appear only in the root module, and downstream modules can simply
# declare resources for that provider and have them automatically associated with the root provider configurations

# https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
module "primary_aurora_postgres_cluster" {
  source  = "cloudposse/rds-cluster/aws"
  version = "0.45.0"

  # You need to specify db name both here and in global cluster for it to be created
  admin_password                      = local.admin_password
  admin_user                          = local.admin_user
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  allowed_cidr_blocks                 = var.allowed_cidr_blocks
  apply_immediately                   = var.apply_immediately
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  autoscaling_enabled                 = var.autoscaling_enabled
  autoscaling_max_capacity            = var.autoscaling_max_capacity
  autoscaling_min_capacity            = var.autoscaling_min_capacity
  autoscaling_policy_type             = var.autoscaling_policy_type
  autoscaling_scale_in_cooldown       = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown      = var.autoscaling_scale_out_cooldown
  autoscaling_target_metrics          = var.autoscaling_target_metrics
  autoscaling_target_value            = var.autoscaling_target_value
  backtrack_window                    = var.backtrack_window
  backup_window                       = var.backup_window
  cluster_dns_name                    = local.primary_cluster_dns_name
  cluster_family                      = var.cluster_family
  cluster_identifier                  = var.cluster_identifier
  cluster_parameters                  = var.cluster_parameters
  cluster_size                        = var.cluster_size
  cluster_type                        = var.cluster_type
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  db_name                             = local.database_name
  db_port                             = var.db_port
  deletion_protection                 = var.deletion_protection
  enable_http_endpoint                = var.enable_http_endpoint
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  enhanced_monitoring_role_enabled    = var.enhanced_monitoring_role_enabled
  global_cluster_identifier           = local.enabled ? aws_rds_global_cluster.default[0].id : ""
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles
  instance_availability_zone          = var.instance_availability_zone
  instance_parameters                 = var.instance_parameters
  instance_type                       = var.instance_type
  kms_key_arn                         = module.kms_key_rds_primary.key_arn
  maintenance_window                  = var.maintenance_window
  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = var.performance_insights_kms_key_id
  publicly_accessible                 = var.publicly_accessible
  rds_monitoring_interval             = var.rds_monitoring_interval
  rds_monitoring_role_arn             = var.rds_monitoring_role_arn
  reader_dns_name                     = local.primary_reader_dns_name
  replication_source_identifier       = var.replication_source_identifier
  restore_to_point_in_time            = var.restore_to_point_in_time
  retention_period                    = var.retention_period
  s3_import                           = var.s3_import
  scaling_configuration               = var.scaling_configuration
  security_groups                     = local.existing_security_groups
  skip_final_snapshot                 = var.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  source_region                       = var.source_region
  storage_encrypted                   = var.storage_encrypted
  subnets                             = local.primary_private_subnet_ids
  timeouts_configuration              = var.timeouts_configuration
  vpc_id                              = local.primary_vpc_id
  vpc_security_group_ids              = var.vpc_security_group_ids
  zone_id                             = local.zone_id

  context = module.cluster.context
}

resource "aws_security_group_rule" "ingress_self" {
  count             = local.enabled ? 1 : 0
  description       = "Allow inbound traffic from self"
  self              = true
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  security_group_id = module.primary_aurora_postgres_cluster.security_group_id
}

# AWS database endpoints and CNAMEs can take a while to propagate.
# It would be nice if we could have a test for when it was ready, but it is complicated, and a sleep will do.
resource "time_sleep" "db_cluster_propagation" {
  count = local.enabled ? 1 : 0

  create_duration = "70s"

  triggers = {
    # This sets up a proper cluster dependency for the Postgres provider
    master_host     = module.primary_aurora_postgres_cluster.master_host
    master_username = module.primary_aurora_postgres_cluster.master_username
    admin_password  = local.admin_password
  }
}

resource "postgresql_database" "additional" {
  for_each   = local.enabled ? var.additional_databases : []
  name       = each.key
  depends_on = [module.primary_aurora_postgres_cluster.cluster_identifier]
}

module "additional_users" {
  for_each = local.enabled ? var.additional_users : {}
  source   = "./modules/postgresql-user"

  service_name    = each.key
  db_user         = each.value.db_user
  db_password     = each.value.db_password
  grants          = each.value.grants
  superuser       = each.value.superuser
  ssm_path_prefix = format("%v/service", local.ssm_key_prefix)

  context = module.this.context

  depends_on = [
    module.primary_aurora_postgres_cluster.cluster_identifier,
    postgresql_database.additional,
  ]
}


resource "aws_ssm_parameter" "primary_aurora_postgres_admin_username" {
  count = local.enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "admin/db_user")
  value       = module.primary_aurora_postgres_cluster.master_username
  description = "Primary Aurora Postgres Username for the master DB user"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}

resource "aws_ssm_parameter" "primary_aurora_postgres_admin_password" {
  count = local.enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "admin/db_password")
  value       = local.admin_password
  description = "Primary Aurora Postgres Password for the master DB user"
  type        = "SecureString"
  key_id      = var.kms_alias_name_ssm
  overwrite   = true

  tags = module.this.tags
}

resource "aws_ssm_parameter" "primary_aurora_postgres_master_hostname" {
  count = local.enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "primary_master_hostname")
  value       = module.primary_aurora_postgres_cluster.master_host
  description = "Primary Aurora Postgres DB Master hostname"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}

resource "aws_ssm_parameter" "primary_aurora_postgres_replicas_hostname" {
  count = local.enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "primary_replicas_hostname")
  value       = module.primary_aurora_postgres_cluster.replicas_host
  description = "Primary Aurora Postgres DB Replicas hostname"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}

resource "aws_ssm_parameter" "primary_aurora_postgres_cluster_name" {
  count = local.enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "primary_cluster_id")
  value       = module.primary_aurora_postgres_cluster.cluster_identifier
  description = "Primary Aurora Postgres DB Cluster Identifier"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}

resource "aws_ssm_parameter" "primary_aurora_postgres_master_port" {
  count = local.enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "db_port")
  value       = var.db_port
  description = "Primary Aurora Postgres DB Master port"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}
