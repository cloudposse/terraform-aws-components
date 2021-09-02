locals {
  vpc_cidr            = module.vpc.outputs.vpc_cidr
  allowed_cidr_blocks = concat([local.vpc_cidr], var.ingress_cidr_blocks)

  eks_cluster_managed_security_group_id = module.eks.outputs.eks_cluster_managed_security_group_id

  global_attributes = {
    vpc_id              = module.vpc.outputs.vpc_id
    allowed_cidr_blocks = local.allowed_cidr_blocks
    subnets             = module.vpc.outputs.private_subnet_ids
    zone_id             = module.dns_delegated.outputs.default_dns_zone_id

    allowed_security_groups = [local.eks_cluster_managed_security_group_id]

    availability_zones               = var.availability_zones
    egress_cidr_blocks               = var.egress_cidr_blocks
    family                           = var.family
    port                             = var.port
    at_rest_encryption_enabled       = var.at_rest_encryption_enabled
    transit_encryption_enabled       = var.transit_encryption_enabled
    apply_immediately                = var.apply_immediately
    automatic_failover_enabled       = var.automatic_failover_enabled
    cloudwatch_metric_alarms_enabled = var.cloudwatch_metric_alarms_enabled
  }

  clusters = module.redis_clusters
}

module "redis_clusters" {
  for_each = var.redis_clusters
  source   = "./modules/redis_cluster"

  cluster_name  = replace(each.key, "_", "-")
  dns_subdomain = replace(each.key, "_", "-")

  instance_type      = each.value.instance_type
  num_replicas       = lookup(each.value, "num_replicas", 1)
  num_shards         = lookup(each.value, "num_shards", 0)
  replicas_per_shard = lookup(each.value, "replicas_per_shard", 0)
  engine_version     = each.value.engine_version
  parameters         = each.value.parameters
  cluster_attributes = local.global_attributes

  context = module.this.context
}
