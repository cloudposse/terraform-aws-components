variable "redis_name" {
  type        = "string"
  default     = "redis"
  description = "Redis name"
}

variable "redis_instance_type" {
  type        = "string"
  default     = "cache.t2.medium"
  description = "EC2 instance type for Redis cluster"
}

variable "redis_cluster_size" {
  type        = "string"
  default     = "2"
  description = "Redis cluster size"
}

variable "redis_cluster_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

variable "redis_auth_token" {
  type        = "string"
  default     = ""
  description = "Auth token for password protecting redis, transit_encryption_enabled must be set to 'true'! Password must be longer than 16 chars"
}

variable "redis_transit_encryption_enabled" {
  type        = "string"
  default     = "true"
  description = "Enable TLS"
}

variable "redis_params" {
  type        = "list"
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from a Redis family to another"
}

module "elasticache_redis" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=tags/0.7.1"
  namespace                    = "${var.namespace}"
  stage                        = "${var.stage}"
  name                         = "${var.redis_name}"
  zone_id                      = "${local.zone_id}"
  security_groups              = ["${module.kops_metadata.nodes_security_group_id}"]
  vpc_id                       = "${module.vpc.vpc_id}"
  subnets                      = ["${module.subnets.private_subnet_ids}"]
  maintenance_window           = "sun:03:00-sun:04:00"
  cluster_size                 = "${var.redis_cluster_size}"
  instance_type                = "${var.redis_instance_type}"
  transit_encryption_enabled   = "${var.redis_transit_encryption_enabled}"
  engine_version               = "3.2.6"
  family                       = "redis3.2"
  port                         = "6379"
  alarm_cpu_threshold_percent  = "75"
  alarm_memory_threshold_bytes = "10000000"
  apply_immediately            = "true"
  availability_zones           = ["${local.availability_zones}"]
  automatic_failover           = "false"
  enabled                      = "${var.redis_cluster_enabled}"
  auth_token                   = "${var.redis_auth_token}"

  parameter = "${var.redis_params}"
}

output "elasticache_redis_id" {
  value = "${module.elasticache_redis.id}"
}

output "elasticache_redis_security_group_id" {
  value = "${module.elasticache_redis.security_group_id}"
}

output "elasticache_redis_host" {
  value = "${module.elasticache_redis.host}"
}
