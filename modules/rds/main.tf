locals {
  enabled = module.this.enabled

  vpc_id     = module.vpc.outputs.vpc_id
  subnet_ids = var.use_private_subnets ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids

  eks_security_groups = var.use_eks_security_group ? [module.eks[0].outputs.eks_cluster_managed_security_group_id] : []
  dns_zone_id         = one(module.dns_gbl_delegated[*].outputs.default_dns_zone_id)

  create_user     = local.enabled && length(var.database_user) == 0
  create_password = local.enabled && length(var.database_password) == 0

  database_user     = local.create_user ? substr(join("", random_pet.database_user.*.id), 0, 16) : var.database_user
  database_password = local.create_password ? join("", random_password.database_password.*.result) : var.database_password

  client_security_group_ids = concat(
    module.this.enabled && var.client_security_group_enabled ? [module.rds_client_sg.id] : [],
    local.eks_security_groups,
    var.security_group_ids
  )

  psql_access_enabled = local.enabled && (var.engine == "postgres")
}

module "rds_client_sg" {
  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  name    = "${module.this.name}-client"
  enabled = module.this.enabled && var.client_security_group_enabled

  vpc_id = local.vpc_id
  rules  = []

  context = module.this.context
}

module "rds_instance" {
  source  = "cloudposse/rds/aws"
  version = "1.1.0"

  allocated_storage                     = var.allocated_storage
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  allowed_cidr_blocks                   = var.allowed_cidr_blocks
  apply_immediately                     = var.apply_immediately
  associate_security_group_ids          = var.associate_security_group_ids
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  availability_zone                     = var.availability_zone
  backup_retention_period               = var.backup_retention_period
  backup_window                         = var.backup_window
  ca_cert_identifier                    = var.ca_cert_identifier
  charset_name                          = var.charset_name
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  database_name                         = var.database_name
  database_password                     = local.database_password
  database_port                         = var.database_port
  database_user                         = local.database_user
  db_options                            = var.db_options
  db_parameter                          = var.db_parameter
  db_parameter_group                    = var.db_parameter_group
  db_subnet_group_name                  = var.db_subnet_group_name
  deletion_protection                   = var.deletion_protection
  dns_zone_id                           = local.dns_zone_id != null ? local.dns_zone_id : ""
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  engine                                = var.engine
  engine_version                        = var.engine_version
  final_snapshot_identifier             = var.final_snapshot_identifier
  host_name                             = var.host_name
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  instance_class                        = var.instance_class
  iops                                  = var.iops
  kms_key_arn                           = var.storage_encrypted ? module.kms_key_rds.key_arn : null
  license_model                         = var.license_model
  maintenance_window                    = var.maintenance_window
  major_engine_version                  = var.major_engine_version
  max_allocated_storage                 = var.max_allocated_storage
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval != "0" ? module.rds_monitoring_role[0].arn : var.monitoring_role_arn
  multi_az                              = var.multi_az
  option_group_name                     = var.option_group_name
  parameter_group_name                  = var.parameter_group_name
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period
  publicly_accessible                   = var.publicly_accessible
  replicate_source_db                   = var.replicate_source_db
  security_group_ids                    = local.client_security_group_ids
  skip_final_snapshot                   = var.skip_final_snapshot
  snapshot_identifier                   = var.snapshot_identifier
  storage_encrypted                     = var.storage_encrypted
  storage_throughput                    = var.storage_throughput
  storage_type                          = var.storage_type
  subnet_ids                            = local.subnet_ids
  timezone                              = var.timezone
  vpc_id                                = local.vpc_id

  context = module.this.context
}

resource "random_pet" "database_user" {
  count = local.create_user ? 1 : 0

  # word length
  length = 5

  separator = ""

  keepers = {
    db_name = var.database_name
  }
}

resource "random_password" "database_password" {
  count = local.create_password ? 1 : 0

  # character length
  length = 33

  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"

  keepers = {
    db_name = var.database_name
  }
}

module "rds_monitoring_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.17.0"

  count = var.monitoring_interval != "0" ? 1 : 0

  name    = "${module.this.name}-rds-enhanced-monitoring-role"
  enabled = module.this.enabled && var.monitoring_interval != 0
  context = module.this.context

  role_description      = "Used for enhanced monitoring of rds"
  policy_document_count = 0
  managed_policy_arns   = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  principals = {
    Service = ["monitoring.rds.amazonaws.com"]
  }
}
