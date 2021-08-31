# https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
module "secondary_aurora_postgres_cluster" {
  source  = "cloudposse/rds-cluster/aws"
  version = "0.45.0"

  enabled = local.secondary_enabled

  # Don't specify username, password and database name for cross region replication secondary cluster
  # https://github.com/terraform-providers/terraform-provider-aws/issues/10188
  admin_password                      = ""
  admin_user                          = ""
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  allowed_cidr_blocks                 = sort(distinct(concat(local.secondary_private_subnet_cidrs, var.allowed_cidr_blocks)))
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
  cluster_dns_name                    = local.secondary_cluster_dns_name
  cluster_family                      = var.cluster_family
  cluster_identifier                  = var.cluster_identifier
  cluster_parameters                  = var.cluster_parameters
  cluster_size                        = var.cluster_size
  cluster_type                        = var.cluster_type
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  db_name                             = ""
  db_port                             = var.db_port
  deletion_protection                 = false
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
  kms_key_arn                         = module.kms_key_rds_secondary.key_arn
  maintenance_window                  = var.maintenance_window
  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = var.performance_insights_kms_key_id
  publicly_accessible                 = var.publicly_accessible
  rds_monitoring_interval             = var.rds_monitoring_interval
  rds_monitoring_role_arn             = var.rds_monitoring_role_arn
  reader_dns_name                     = local.secondary_reader_dns_name
  replication_source_identifier       = var.replication_source_identifier
  restore_to_point_in_time            = var.restore_to_point_in_time
  retention_period                    = var.retention_period
  s3_import                           = var.s3_import
  scaling_configuration               = var.scaling_configuration
  security_groups                     = []
  skip_final_snapshot                 = var.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  subnets                             = local.secondary_private_subnet_ids
  timeouts_configuration              = var.timeouts_configuration
  vpc_id                              = local.secondary_vpc_id
  vpc_security_group_ids              = var.vpc_security_group_ids
  zone_id                             = ""

  # Source Region of primary cluster, needed when using encrypted storage and region replicas
  source_region = var.region

  # https://www.terraform.io/docs/configuration/modules.html#passing-providers-explicitly
  providers = {
    aws = aws.secondary
  }

  depends_on = [module.primary_aurora_postgres_cluster]

  environment = var.environment_secondary
  context     = module.cluster.context
}

locals {
  secondary_enabled = local.enabled && var.secondary_region_enabled

  secondary_vpc_id               = local.secondary_enabled ? module.vpc_secondary[0].outputs.vpc_id : null
  secondary_private_subnet_ids   = local.secondary_enabled ? module.vpc_secondary[0].outputs.private_subnet_ids : []
  secondary_private_subnet_cidrs = local.secondary_enabled ? module.vpc_secondary[0].outputs.private_subnet_cidrs : []
  secondary_cluster_dns_name     = format("%v%v", local.cluster_dns_name_prefix, var.secondary_cluster_dns_name_part)
  secondary_reader_dns_name      = format("%v%v", local.cluster_dns_name_prefix, var.secondary_reader_dns_name_part)

  secondary_aurora_postgres_cluster_reader_endpoint = (local.secondary_enabled ?
    length(module.secondary_aurora_postgres_cluster.replicas_host) > 0 ? module.secondary_aurora_postgres_cluster.replicas_host : module.secondary_aurora_postgres_cluster.reader_endpoint
  : null)
}

resource "aws_ssm_parameter" "secondary_aurora_postgres_replicas_hostname" {
  count = local.secondary_enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "secondary_reader_endpoint")
  value       = local.secondary_aurora_postgres_cluster_reader_endpoint
  description = "Secondary Aurora Postgres DB Replicas hostname"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}

resource "aws_ssm_parameter" "secondary_aurora_postgres_cluster_name" {
  count = local.secondary_enabled ? 1 : 0

  name        = format("%s/%s", local.ssm_key_prefix, "secondary_cluster_id")
  value       = module.secondary_aurora_postgres_cluster.cluster_identifier
  description = "Secondary Aurora Postgres DB Cluster Identifier"
  type        = "String"
  overwrite   = true

  tags = module.this.tags
}
