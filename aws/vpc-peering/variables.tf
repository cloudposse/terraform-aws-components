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
