variable "permitted_nodes" {
  type = "string"

  # Set to 'masters' if using kiam to control roles
  default     = "both"
  description = "Kops kubernetes nodes that are permitted to assume IAM roles (e.g. 'nodes', 'masters', 'both' or 'any')"
}

variable "cluster_name" {
  type        = "string"
  description = "Kops cluster name (e.g. `us-east-1.prod.cloudposse.co` or `cluster-1.cloudposse.co`)"
}

variable "aws_assume_role_arn" {
  type        = "string"
  description = "AWS IAM Role for Terraform to assume during operation"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "kubernetes_namespace" {
  type        = "string"
  description = "Kubernetes namespace in which to place Teleport resources"
  default     = "teleport"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = "string"
  description = "The name of the app"
  default     = "teleport"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "teleport_version" {
  type        = "string"
  description = "Version number of Teleport to install (e.g. \"4.0.9\")"
}

variable "teleport_proxy_domain_name" {
  type        = "string"
  description = "Domain name to use for Teleport Proxy"
}

variable "masters_name" {
  type        = "string"
  default     = "masters"
  description = "Kops masters subdomain name in the cluster DNS zone"
}

variable "nodes_name" {
  type        = "string"
  default     = "nodes"
  description = "Kops nodes subdomain name in the cluster DNS zone"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  default = "/%s/%s"
}

variable "s3_prefix" {
  type        = "string"
  description = "S3 bucket prefix"
  default     = ""
}

variable "s3_standard_transition_days" {
  type        = "string"
  description = "Number of days to persist in the standard storage tier before moving to the glacier tier"
  default     = "30"
}

variable "s3_glacier_transition_days" {
  type        = "string"
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "60"
}

variable "s3_expiration_days" {
  type        = "string"
  description = "Number of days after which to expunge the objects"
  default     = "90"
}

# Autoscale min_read and min_write capacity will set the provisioned capacity for both cluster state and audit events
variable "autoscale_min_read_capacity" {
  default = 10
}

variable "autoscale_min_write_capacity" {
  default = 10
}

# Currently the autoscalers for the cluster state and the audit events share the same settings
variable "autoscale_write_target" {
  default = 50
}

variable "autoscale_read_target" {
  default = 50
}

variable "autoscale_max_read_capacity" {
  default = 100
}

variable "autoscale_max_write_capacity" {
  default = 100
}

variable "iam_role_max_session_duration" {
  default     = 3600
  description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours"
}
