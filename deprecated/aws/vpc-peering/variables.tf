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

variable "requester_account" {
  description = "Account name of the requester (e.g. `prod` or `staging`). Used to look up the role ARN from SSM"
}

variable "requester_region" {
  description = "Region of the requester's VPC"
}

variable "requester_vpc_tags" {
  type        = "map"
  description = "Tags to filter for the requester's VPC"
  default     = {}
}

variable "accepter_region" {
  description = "Region of the accepter's VPC"
}

variable "accepter_account" {
  description = "Account name of the accepter (e.g. `prod` or `staging`). Used to look up the role ARN from SSM"
}

variable "accepter_vpc_tags" {
  type        = "map"
  description = "Tags to filter for the accepter's VPC"
  default     = {}
}
