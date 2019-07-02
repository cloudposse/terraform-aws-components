terraform {
  required_version = "~> 0.11.2"

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

variable "cluster_name" {
  type        = "string"
  description = "kops cluster name"
}

variable "external_principals_full_access" {
  type        = "list"
  description = "Principal ARN to provide with full access to the ECR"
  default     = []
}

variable "external_principals_readonly_access" {
  type        = "list"
  description = "Principal ARN to provide with readonly access to the ECR"
  default     = []
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

locals {
  principals_full_access     = ["${concat(list(module.kops_ecr_user.user_arn), var.external_principals_full_access)}"]
  principals_readonly_access = ["${concat(list(module.kops_metadata.masters_role_arn, module.kops_metadata.nodes_role_arn), var.external_principals_readonly_access)}"]
}

module "label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.5.4"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "ecr"
  tags      = "${map("Cluster", var.cluster_name)}"
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.1.0"
  cluster_name = "${var.cluster_name}"
}
