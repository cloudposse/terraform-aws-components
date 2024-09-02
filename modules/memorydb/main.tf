locals {
  vpc                = module.vpc.outputs
  private_subnet_ids = local.vpc.private_subnet_ids

  default_ssm_parameter_name = "/${module.this.id}/admin_password"
  ssm_parameter_name         = var.ssm_parameter_name == "" ? local.default_ssm_parameter_name : var.ssm_parameter_name
}

module "memorydb" {
  source  = "cloudposse/memorydb/aws"
  version = "0.1.0"

  node_type                  = var.node_type
  num_shards                 = var.num_shards
  num_replicas_per_shard     = var.num_replicas_per_shard
  tls_enabled                = var.tls_enabled
  engine_version             = var.engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  subnet_ids                 = local.private_subnet_ids
  security_group_ids         = var.security_group_ids
  port                       = var.port
  maintenance_window         = var.maintenance_window

  snapshot_window          = var.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_arns            = var.snapshot_arns
  sns_topic_arn            = var.sns_topic_arn

  admin_username = var.admin_username

  ssm_parameter_name = local.ssm_parameter_name

  parameter_group_family = var.parameter_group_family
  parameters             = var.parameters

  context = module.this.context
}
