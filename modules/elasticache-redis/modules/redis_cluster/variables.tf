# API Response Redis Cluster Vars

variable "cluster_name" {
  type        = string
  description = "Elasticache Cluster name"
}

variable "create_parameter_group" {
  type        = bool
  default     = true
  description = "Whether new parameter group should be created. Set to false if you want to use existing parameter group"
}

variable "engine" {
  type        = string
  default     = "redis"
  description = "Name of the cache engine to use: either `redis` or `valkey`"
}

variable "engine_version" {
  type        = string
  description = "Version of the cache engine to use"
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
    availability_zones              = list(string)
    vpc_id                          = string
    additional_security_group_rules = list(any)
    allowed_security_groups         = list(string)
    allow_all_egress                = bool
    subnets                         = list(string)
    family                          = string
    port                            = number
    zone_id                         = string
    multi_az_enabled                = bool
    at_rest_encryption_enabled      = bool
    transit_encryption_enabled      = bool
    apply_immediately               = bool
    automatic_failover_enabled      = bool
    auto_minor_version_upgrade      = bool
    auth_token_enabled              = bool
    snapshot_retention_limit        = number
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

variable "parameter_group_name" {
  type        = string
  default     = null
  description = "Override the default parameter group name"
}

variable "kms_alias_name_ssm" {
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}
