locals {
  enabled = module.this.enabled

  auth_token_enabled = local.enabled && var.cluster_attributes.transit_encryption_enabled && var.cluster_attributes.auth_token_enabled

  ssm_path_auth_token = local.auth_token_enabled ? format("/%s/%s/%s", "elasticache-redis", var.cluster_name, "auth_token") : null

  auth_token = local.auth_token_enabled ? join("", random_password.auth_token.*.result) : null
}

module "redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.44.0"

  name = var.cluster_name

  additional_security_group_rules      = var.cluster_attributes.additional_security_group_rules
  allow_all_egress                     = var.cluster_attributes.allow_all_egress
  allowed_security_group_ids           = var.cluster_attributes.allowed_security_groups
  apply_immediately                    = var.cluster_attributes.apply_immediately
  at_rest_encryption_enabled           = var.cluster_attributes.at_rest_encryption_enabled
  auth_token                           = local.auth_token
  automatic_failover_enabled           = var.cluster_attributes.automatic_failover_enabled
  availability_zones                   = var.cluster_attributes.availability_zones
  cluster_mode_enabled                 = var.num_shards > 0
  cluster_mode_num_node_groups         = var.num_shards
  cluster_mode_replicas_per_node_group = var.replicas_per_shard
  cluster_size                         = var.num_replicas
  dns_subdomain                        = var.dns_subdomain
  engine_version                       = var.engine_version
  family                               = var.cluster_attributes.family
  instance_type                        = var.instance_type
  parameter                            = var.parameters
  port                                 = var.cluster_attributes.port
  subnets                              = var.cluster_attributes.subnets
  transit_encryption_enabled           = var.cluster_attributes.transit_encryption_enabled
  vpc_id                               = var.cluster_attributes.vpc_id
  zone_id                              = var.cluster_attributes.zone_id

  context = module.this.context
}

# https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/auth.html
resource "random_password" "auth_token" {
  count = local.auth_token_enabled ? 1 : 0

  # min 16, max 128
  length  = 128
  special = true

  # Original chars
  # override_special = "!&#$^<>-"
  # Removed $ and ! to avoid issues with environment variables
  override_special = "#^-"

  min_upper   = 3
  min_lower   = 3
  min_numeric = 3
  min_special = 3

  keepers = {
    cluster_name = var.cluster_name
  }
}

module "parameter_store_write" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  enabled = local.auth_token_enabled

  kms_arn = var.kms_alias_name_ssm

  parameter_write = [
    {
      name        = local.ssm_path_auth_token
      value       = local.auth_token
      description = "Redis auth_token"
      type        = "SecureString"
      overwrite   = true
    },
  ]

  context = module.this.context
}
