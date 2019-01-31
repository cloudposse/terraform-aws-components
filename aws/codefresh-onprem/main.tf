terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
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

data "terraform_remote_state" "backing_services" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "backing-services/terraform.tfstate"
  }
}

module "codefresh_enterprise_backing_services" {
  source          = "git::https://github.com/cloudposse/terraform-aws-codefresh-backing-services.git?ref=tags/0.2.0"
  namespace       = "${var.namespace}"
  stage           = "${var.stage}"
  vpc_id          = "${data.terraform_remote_state.backing_services.vpc_id}"
  subnet_ids      = ["${data.terraform_remote_state.backing_services.private_subnet_ids}"]
  security_groups = ["${module.kops_metadata.nodes_security_group_id}"]
  zone_name       = "${var.zone_name}"
  chamber_service = "codefresh"
}

output "elasticache_redis_id" {
  value       = "${module.codefresh_enterprise_backing_services.elasticache_redis_id}"
  description = "Elasticache Redis cluster ID"
}

output "elasticache_redis_security_group_id" {
  value       = "${module.codefresh_enterprise_backing_services.elasticache_redis_security_group_id}"
  description = "Elasticache Redis security group ID"
}

output "elasticache_redis_host" {
  value       = "${module.codefresh_enterprise_backing_services.elasticache_redis_security_group_id}"
  description = "Elasticache Redis host"
}

output "aurora_postgres_database_name" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_database_name}"
  description = "Aurora Postgres Database name"
}

output "aurora_postgres_master_username" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_master_username}"
  description = "Aurora Postgres Username for the master DB user"
}

output "aurora_postgres_master_hostname" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_master_hostname}"
  description = "Aurora Postgres DB Master hostname"
}

output "aurora_postgres_replicas_hostname" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_replicas_hostname}"
  description = "Aurora Postgres Replicas hostname"
}

output "aurora_postgres_cluster_name" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_cluster_name}"
  description = "Aurora Postgres Cluster Identifier"
}

output "s3_user_name" {
  value       = "${module.codefresh_enterprise_backing_services.s3_user_name}"
  description = "Normalized IAM user name"
}

output "s3_user_arn" {
  value       = "${module.codefresh_enterprise_backing_services.s3_user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "s3_user_unique_id" {
  value       = "${module.codefresh_enterprise_backing_services.s3_user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "s3_access_key_id" {
  sensitive   = true
  value       = "${module.codefresh_enterprise_backing_services.s3_access_key_id}"
  description = "The access key ID"
}

output "s3_secret_access_key" {
  sensitive   = true
  value       = "${module.codefresh_enterprise_backing_services.s3_secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "s3_bucket_arn" {
  value       = "${module.codefresh_enterprise_backing_services.s3_bucket_arn}"
  description = "The s3 bucket ARN"
}
