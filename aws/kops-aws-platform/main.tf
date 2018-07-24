terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "permitted_nodes" {
  type        = "string"
  description = "Kops kubernetes nodes that are permitted to assume the role (e.g. 'nodes', 'masters', or 'both')"
  default     = "masters"
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}
