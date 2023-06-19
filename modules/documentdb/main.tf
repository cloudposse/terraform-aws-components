locals {
  enabled = module.this.enabled
}

module "documentdb_cluster" {
  source  = "cloudposse/documentdb-cluster/aws"
  version = "0.14.0"

  instance_class                  = var.instance_class
  cluster_size                    = var.cluster_size
  cluster_family                  = var.cluster_family
  cluster_parameters              = var.cluster_parameters
  engine                          = var.engine
  engine_version                  = var.engine_version
  deletion_protection             = var.deletion_protection_enabled
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  storage_encrypted               = var.encryption_enabled

  snapshot_identifier          = var.snapshot_identifier
  retention_period             = var.retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  skip_final_snapshot          = var.skip_final_snapshot

  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  db_port         = var.db_port
  master_username = join("", aws_ssm_parameter.master_username.*.value)
  master_password = join("", aws_ssm_parameter.master_password.*.value)

  vpc_id                  = module.vpc.outputs.vpc_id
  subnet_ids              = module.vpc.outputs.private_subnet_ids
  allowed_security_groups = compact([module.eks.outputs.eks_cluster_managed_security_group_id])
  zone_id                 = try(module.dns_delegated.outputs.default_dns_zone_id, module.dns_gbl_delegated.outputs.default_dns_zone_id)

  context = module.this.context
}
