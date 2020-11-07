variable "aws_assume_role_arn" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "elasticache_availability_zones" {
  type        = list(string)
  description = "AWS region availability zones for elasticache (e.g.: ['us-west-2a', 'us-west-2b']). If empty will use all available zones"
  default     = []
}

variable "kops_cluster_name" {
  type        = string
  description = "Name of the kops cluster, e.g. us-west-2.prod.cpco.io"
}

variable "chamber_service" {
  type        = string
  default     = "kops"
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

