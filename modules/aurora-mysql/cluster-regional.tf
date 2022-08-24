module "aurora_mysql" {
  source  = "cloudposse/rds-cluster/aws"
  version = "1.3.1"

  enabled    = local.mysql_enabled
  attributes = [var.mysql_name]

  engine              = var.aurora_mysql_engine
  engine_version      = var.aurora_mysql_engine_version
  cluster_family      = var.aurora_mysql_cluster_family
  cluster_parameters  = var.aurora_mysql_cluster_parameters
  cluster_size        = var.mysql_cluster_size
  cluster_type        = "regional"
  instance_parameters = var.aurora_mysql_instance_parameters
  instance_type       = var.mysql_instance_type

  db_name        = local.mysql_db_name
  db_port        = 3306
  admin_password = local.mysql_admin_password
  admin_user     = local.mysql_admin_user

  vpc_id              = local.vpc_id
  publicly_accessible = var.publicly_accessible
  subnets             = var.publicly_accessible ? local.public_subnet_ids : local.private_subnet_ids
  allowed_cidr_blocks = var.publicly_accessible ? coalescelist(var.allowed_cidr_blocks, ["0.0.0.0/0"]) : var.allowed_cidr_blocks
  security_groups     = [local.eks_cluster_managed_security_group_id]

  zone_id          = local.zone_id
  cluster_dns_name = "master.${local.cluster_subdomain}"
  reader_dns_name  = "readers.${local.cluster_subdomain}"

  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  deletion_protection             = var.mysql_deletion_protection
  enabled_cloudwatch_logs_exports = var.mysql_enabled_cloudwatch_logs_exports
  copy_tags_to_snapshot           = true
  skip_final_snapshot             = var.mysql_skip_final_snapshot

  backup_window      = var.mysql_backup_window
  maintenance_window = var.mysql_maintenance_window
  retention_period   = var.mysql_backup_retention_period

  storage_encrypted               = var.mysql_storage_encrypted
  kms_key_arn                     = var.mysql_storage_encrypted ? module.kms_key_rds.key_arn : null
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled ? module.kms_key_rds.key_arn : null

  context = module.this.context
}
