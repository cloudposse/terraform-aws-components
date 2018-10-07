variable "REDIS_INSTANCE_TYPE" {
  type        = "string"
  default     = "cache.t2.medium"
  description = "EC2 instance type for Redis cluster"
}

variable "REDIS_CLUSTER_SIZE" {
  type        = "string"
  default     = "2"
  description = "Redis cluster size"
}

variable "REDIS_CLUSTER_ENABLED" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

module "elasticache_redis" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=tags/0.7.0"
  namespace                    = "${var.namespace}"
  stage                        = "${var.stage}"
  name                         = "redis"
  zone_id                      = "${var.zone_id}"
  security_groups              = ["${module.kops_metadata.nodes_security_group_id}"]
  vpc_id                       = "${module.vpc.vpc_id}"
  subnets                      = ["${module.subnets.private_subnet_ids}"]
  maintenance_window           = "sun:03:00-sun:04:00"
  cluster_size                 = "${var.REDIS_CLUSTER_SIZE}"
  instance_type                = "${var.REDIS_INSTANCE_TYPE}"
  engine_version               = "3.2.4"
  family                       = "redis3.2"
  port                         = "6379"
  alarm_cpu_threshold_percent  = "75"
  alarm_memory_threshold_bytes = "10000000"
  apply_immediately            = "true"
  availability_zones           = ["${data.aws_availability_zones.available.names}"]
  automatic_failover           = "false"
  enabled                      = "${var.REDIS_CLUSTER_ENABLED}"
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
