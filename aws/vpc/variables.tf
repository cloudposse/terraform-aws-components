variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Name to distinguish this VPC from others in this account"
  default     = "vpc"
}

variable "attributes" {
  type        = "list"
  description = "Additional attributes to distinguish this VPC from others in this account"
  default     = ["common"]
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags, for example map(`KubernetesCluster`,`us-west-2.prod.example.com`)"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_nat_gateway_enabled" {
  default = "true"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  description = "format string for creating SSM parameter name used to store chamber parameters"
  default     = "/%s/%s_%s"
}
