variable "aws_assume_role_arn" {}

variable "enabled" {
  type        = "string"
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = "true"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Application or solution name (e.g. `app`)"
  default     = "vpc-peering"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "legacy_account_assume_role_arn" {
  type        = "string"
  description = "Legacy account assume role ARN"
}

variable "legacy_account_region" {
  type        = "string"
  description = "Legacy account AWS region"
}

variable "legacy_account_vpc_id" {
  type        = "string"
  description = "Legacy account VPC ID"
}
