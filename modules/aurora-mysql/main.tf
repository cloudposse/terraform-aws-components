locals {
  enabled = module.this.enabled

  vpc_outputs           = module.vpc.outputs
  dns_delegated_outputs = module.dns-delegated.outputs
  vpc_id                = local.vpc_outputs.vpc_id
  public_subnet_ids     = local.vpc_outputs.public_subnet_ids
  private_subnet_ids    = local.vpc_outputs.private_subnet_ids
  zone_id               = local.dns_delegated_outputs.default_dns_zone_id

  eks_cluster_managed_security_group_ids = [for cluster in module.eks : cluster.outputs.eks_cluster_managed_security_group_id]

  # Read Replication uses either an explicit ARN of the replication source or Remote State from the primary region
  is_read_replica             = local.enabled && var.is_read_replica
  remote_read_replica_enabled = local.is_read_replica && !(length(var.replication_source_identifier) > 0) && length(var.primary_cluster_region) > 0

  # Removing the replicate source attribute from an existing RDS Replicate database managed by Terraform
  # should promote the database to a fully standalone database but currently is not supported by Terraform.
  # Instead, first manually promote with the AWS CLI or console, and then remove the replication source identifier from the Terraform state
  # See https://github.com/hashicorp/terraform-provider-aws/issues/6749
  replication_source_identifier = local.remote_read_replica_enabled && !var.is_promoted_read_replica ? module.primary_cluster[0].outputs.aurora_mysql_cluster_arn : var.replication_source_identifier

  # For encrypted cross-region replica, kmsKeyId should be explicitly specified
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html
  # A read replica of an Amazon RDS encrypted instance must be encrypted using the same KMS key as the primary DB instance when both are in the same AWS Region.
  # If the primary DB instance and read replica are in different AWS Regions, you encrypt the read replica using a KMS key in that AWS Region.
  kms_key_arn = module.kms_key_rds.key_arn

  # Do not create a DB & DB resources if Read Replication is enabled
  mysql_db_enabled     = local.enabled && !local.is_read_replica
  mysql_db_name        = length(var.mysql_db_name) > 0 ? var.mysql_db_name : join("", random_pet.mysql_db_name.*.id)
  mysql_admin_user     = length(var.mysql_admin_user) > 0 ? var.mysql_admin_user : join("", random_pet.mysql_admin_user.*.id)
  fetch_admin_password = local.mysql_db_enabled && length(var.ssm_password_source) > 0
  mysql_admin_password = local.fetch_admin_password ? data.aws_ssm_parameter.password[0].value : (
    length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : join("", random_password.mysql_admin_password.*.result)
  )

  cluster_domain    = trimprefix(module.aurora_mysql.endpoint, "${module.aurora_mysql.cluster_identifier}.cluster-")
  cluster_subdomain = var.mysql_name == "" ? module.this.name : "${var.mysql_name}.${module.this.name}"

  # Join a list of all allowed cidr blocks from:
  # 1. VPCs from all given accounts
  # 2. Additionally given CIDR blocks
  all_allowed_cidr_blocks = concat(
    var.allowed_cidr_blocks,
    [
      for k in keys(module.vpc_ingress) :
      module.vpc_ingress[k].outputs.vpc_cidr
    ]
  )
  allowed_cidr_blocks = var.publicly_accessible ? coalescelist(local.all_allowed_cidr_blocks, ["0.0.0.0/0"]) : local.all_allowed_cidr_blocks
}

module "cluster" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = [var.mysql_name]

  context = module.this.context
}

resource "random_pet" "mysql_admin_user" {
  count     = local.mysql_db_enabled && length(var.mysql_admin_user) == 0 ? 1 : 0
  length    = 2
  separator = "_"
}

resource "random_password" "mysql_admin_password" {
  count   = local.mysql_db_enabled && length(var.mysql_admin_password) == 0 && local.fetch_admin_password == false ? 1 : 0
  length  = 33
  special = false
}

resource "random_pet" "mysql_db_name" {
  count = local.mysql_db_enabled && length(var.mysql_db_name) == 0 ? 1 : 0

  separator = "_"

  keepers = {
    cluster_name = var.mysql_name
    db_name      = var.mysql_db_name
  }
}
