# API Response Redis Cluster Vars

variable "cluster_name" {
  type        = string
  description = "Elasticache Cluster name"
}

variable "engine_version" {
  type        = string
  description = "Redis Version"
  default     = "6.0.5"
}

variable "dns_subdomain" {
  type        = string
  description = "Name of DNS subdomain to prepend to Route53 zone DNS name"
}

variable "num_replicas" {
  type        = number
  description = "Number of replicas in replica set"
}

variable "instance_type" {
  type        = string
  description = "Elastic cache instance type"
}

variable "num_shards" {
  type        = number
  description = "Number of node groups (shards) for this Redis cluster. Value > 0 sets cluster mode to true.  Changing this number will trigger an online resizing operation before other settings modifications"
  default     = 0
}

variable "replicas_per_shard" {
  type        = number
  description = "Number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will force a new resource"
  default     = 0
}

variable "cluster_attributes" {
  type = object({
    availability_zones         = list(string)
    vpc_id                     = string
    allowed_cidr_blocks        = list(string)
    allowed_security_groups    = list(string)
    egress_cidr_blocks         = list(string)
    subnets                    = list(string)
    family                     = string
    port                       = number
    zone_id                    = string
    at_rest_encryption_enabled = bool
    transit_encryption_enabled = bool
    apply_immediately          = bool
    automatic_failover_enabled = bool
  })
  description = "Cluster attributes"
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Parameters to configure cluster parameter group"
}
