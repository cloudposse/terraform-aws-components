module "redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.37.0"

  name                                 = var.cluster_name
  engine_version                       = var.engine_version
  dns_subdomain                        = var.dns_subdomain
  instance_type                        = var.instance_type
  cluster_size                         = var.num_replicas
  cluster_mode_enabled                 = var.num_shards > 0 ? true : false
  cluster_mode_num_node_groups         = var.num_shards
  cluster_mode_replicas_per_node_group = var.replicas_per_shard

  availability_zones         = var.cluster_attributes.availability_zones
  vpc_id                     = var.cluster_attributes.vpc_id
  allowed_cidr_blocks        = var.cluster_attributes.allowed_cidr_blocks
  allowed_security_groups    = var.cluster_attributes.allowed_security_groups
  egress_cidr_blocks         = var.cluster_attributes.egress_cidr_blocks
  subnets                    = var.cluster_attributes.subnets
  family                     = var.cluster_attributes.family
  port                       = var.cluster_attributes.port
  zone_id                    = var.cluster_attributes.zone_id
  at_rest_encryption_enabled = var.cluster_attributes.at_rest_encryption_enabled
  transit_encryption_enabled = var.cluster_attributes.transit_encryption_enabled
  apply_immediately          = var.cluster_attributes.apply_immediately
  automatic_failover_enabled = var.cluster_attributes.automatic_failover_enabled

  parameter = var.parameters

  context = module.this.context
}
