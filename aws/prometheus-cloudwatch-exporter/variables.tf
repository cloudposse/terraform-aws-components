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
  default     = "cloudwatch"
  description = "Kubernetes namespace in which to deploy prometheus-cloudwatch-exporter"
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
  description = "The name of the app"
}

variable "kops_cluster_name" {
  type        = string
  description = "The name of the kops cluster (used for finding kops IAM roles)"
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
