terraform {
  backend "s3" {}
}

provider "aws" {
  assume_role { role_arn = var.aws_assume_role_arn }
}

variable "aws_assume_role_arn" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "cloudwatch_namespace" {
  type        = string
  default     = ""
  description = "Kubernetes namespace in which to deploy prometheus-cloudwatch-exporter. Default is no namespace created."
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "name" {
  type        = string
  default     = "prometheus-cloudwatch-exporter"
  description = "The base name of the role"
}

variable "kops_cluster_name" {
  type        = string
  description = "The name of the kops cluster (used for finding kops IAM roles)"
}

variable "assume_role_permitted_roles" {
  type        = string
  description = "Roles that are permitted to assume this role. One of 'kiam', 'nodes', 'masters', or 'both' (nodes + masters)."
  default     = "kiam"
}

variable "chamber_service" {
  type        = string
  default     = "grafana"
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name_pattern" {
  type        = string
  default     = "/%s/%s"
  description = "Format string for creating SSM parameter name used to store chamber parameters. The default is usually best."
}

variable "chamber_kms_key_id" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS key ID, ARN, or alias to use for encrypting SSM secrets"
}

variable "max_session_duration" {
  default     = 3600
  description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours"
}
