variable "redis_name" {
  type        = string
  default     = "redis"
  description = "Redis name"
}

variable "redis_instance_type" {
  type        = string
  default     = "cache.t2.medium"
  description = "EC2 instance type for Redis cluster"
}

variable "redis_cluster_size" {
  type        = number
  default     = 2
  description = "Redis cluster size"
}

variable "redis_cluster_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "redis_params" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = [{ name = "maxmemory-policy", value = "allkeys-lru" }]
  description = "A list of Redis parameters to apply. Note that parameters may differ from a Redis family to another"
}

module "elasticache_redis" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=tags/0.13.0"
  enabled                      = var.redis_cluster_enabled
  namespace                    = var.namespace
  stage                        = var.stage
  name                         = var.redis_name
  attributes                   = ["sentry"]
  zone_id                      = local.zone_id
  security_groups              = [module.kops_metadata.nodes_security_group_id]
  vpc_id                       = module.kops_metadata.vpc_id
  subnets                      = module.kops_metadata.private_subnet_ids
  maintenance_window           = "sun:03:00-sun:04:00"
  cluster_size                 = var.redis_cluster_size
  instance_type                = var.redis_instance_type
  engine_version               = "4.0.10"
  family                       = "redis4.0"
  port                         = 6379
  alarm_cpu_threshold_percent  = 75
  alarm_memory_threshold_bytes = 10000000
  apply_immediately            = true
  availability_zones           = local.availability_zones
  automatic_failover           = true

  transit_encryption_enabled = false # not supported by Sentry https://github.com/getsentry/sentry/issues/11309
  auth_token                 = null  # must set transit_encryption_enabled true first

  parameter = var.redis_params
}

resource "aws_ssm_parameter" "elasticache_redis_host" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_redis_host")
  value       = module.elasticache_redis.host
  description = "Elasticache host for Sentry"
  type        = "String"
  overwrite   = true
}

output "elasticache_redis_id" {
  value = module.elasticache_redis.id
}

output "elasticache_redis_security_group_id" {
  value = module.elasticache_redis.security_group_id
}

output "elasticache_redis_host" {
  value = module.elasticache_redis.host
}
