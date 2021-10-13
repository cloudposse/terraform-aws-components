variable "aws_assume_role_arn" {
  type        = "string"
  description = "AWS IAM Role for Terraform to assume during operation"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "dns_zone_names" {
  type        = "list"
  description = "Names of zones for external-dns to manage (e.g. `us-east-1.cloudposse.com` or `cluster-1.cloudposse.com`)"
}

variable "permitted_nodes" {
  type        = "string"
  description = "Kops kubernetes nodes that are permitted to assume IAM roles (e.g. 'nodes', 'masters', or 'both')"
  default     = "both"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "chamber_service" {
  type        = "string"
  default     = "kops"
  description = "Service under which to store SSM parameters"
}

variable "chamber_service_kops" {
  type        = "string"
  default     = "kops"
  description = "Service where kops stores its configuration information"
}

variable "iam_role_max_session_duration" {
  default     = 3600
  description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours"
}
