variable "region" {
  type        = string
  description = "AWS region"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zone IDs"
  default     = []
}

variable "family" {
  type        = string
  description = "Redis family"
}

variable "port" {
  type        = number
  description = "Port number"
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for permitted ingress"
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for permitted egress"
}

variable "at_rest_encryption_enabled" {
  type        = bool
  description = "Enable encryption at rest"
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "Enable TLS"
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately"
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "Enable automatic failover"
}

variable "cloudwatch_metric_alarms_enabled" {
  type        = bool
  description = "Boolean flag to enable/disable CloudWatch metrics alarms"
}

variable "redis_clusters" {
  type        = map(any)
  description = "Redis cluster configuration"
}
