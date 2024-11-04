locals {
  enabled = module.this.enabled

  eks_security_group_enabled = local.enabled && var.eks_security_group_enabled

  allowed_cidr_blocks = concat(
    var.allow_ingress_from_this_vpc ? [module.vpc.outputs.vpc_cidr] : [],
    var.ingress_cidr_blocks,
    [
      for k in keys(module.vpc_ingress) :
      module.vpc_ingress[k].outputs.vpc_cidr
    ]
  )

  allowed_security_groups = [
    for eks in module.eks :
    eks.outputs.eks_cluster_managed_security_group_id
  ]

  sg_rule_ingress = [
    {
      key         = "in"
      type        = "ingress"
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = local.allowed_cidr_blocks
      description = "Selectively allow inbound traffic"
    }
  ]

  additional_security_group_rules = length(local.allowed_cidr_blocks) > 0 ? local.sg_rule_ingress : []

  # global attributes
  cluster_attributes = {
    vpc_id             = module.vpc.outputs.vpc_id
    subnets            = module.vpc.outputs.private_subnet_ids
    availability_zones = var.availability_zones
    multi_az_enabled   = var.multi_az_enabled

    allowed_security_groups         = local.allowed_security_groups
    additional_security_group_rules = local.additional_security_group_rules
    allow_all_egress                = var.allow_all_egress

    zone_id                          = module.dns_delegated.outputs.default_dns_zone_id
    family                           = var.family
    port                             = var.port
    at_rest_encryption_enabled       = var.at_rest_encryption_enabled
    transit_encryption_enabled       = var.transit_encryption_enabled
    apply_immediately                = var.apply_immediately
    automatic_failover_enabled       = var.automatic_failover_enabled
    auto_minor_version_upgrade       = var.auto_minor_version_upgrade
    cloudwatch_metric_alarms_enabled = var.cloudwatch_metric_alarms_enabled
    auth_token_enabled               = var.auth_token_enabled
    snapshot_retention_limit         = var.snapshot_retention_limit
  }

  clusters = module.redis_clusters
}

module "redis_clusters" {
  source = "./modules/redis_cluster"

  for_each = var.redis_clusters

  cluster_name  = lookup(each.value, "cluster_name", replace(each.key, "_", "-"))
  dns_subdomain = join(".", [lookup(each.value, "cluster_name", replace(each.key, "_", "-")), module.this.environment])

  instance_type          = each.value.instance_type
  num_replicas           = lookup(each.value, "num_replicas", 1)
  num_shards             = lookup(each.value, "num_shards", 0)
  replicas_per_shard     = lookup(each.value, "replicas_per_shard", 0)
  engine                 = lookup(each.value, "engine", "redis")
  engine_version         = each.value.engine_version
  create_parameter_group = lookup(each.value, "create_parameter_group", true)
  parameters             = lookup(each.value, "parameters", null)
  parameter_group_name   = lookup(each.value, "parameter_group_name", null)
  cluster_attributes     = local.cluster_attributes

  context = module.this.context
}
