terraform {
  required_version = ">= 0.11.2"
  backend          "s3"             {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

module "kops_metadata_vpc" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-network.git?ref=tags/0.1.1"
  cluster_name = "${var.kops_cluster_name}"
  vpc_id       = "${var.vpc_id}"
}

locals {
  zone_id                  = "${join("", data.aws_route53_zone.default.*.zone_id)}"
  chamber_service          = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
  postgres_cluster_enabled = "${var.postgres_cluster_enabled == "true"}"
  postgres_admin_user      = "${length(var.postgres_admin_user) > 0 ? var.postgres_admin_user : join("", random_string.postgres_admin_user.*.result)}"
  postgres_admin_password  = "${length(var.postgres_admin_password) > 0 ? var.postgres_admin_password : join("", random_string.postgres_admin_password.*.result)}"
  postgres_db_name         = "${length(var.postgres_db_name) > 0 ? var.postgres_db_name : join("", random_pet.postgres_db_name.*.id)}"
  kms_key_id               = "${length(var.kms_key_id) > 0 ? var.kms_key_id : format("alias/%s-%s-chamber", var.namespace, var.stage)}"
}

data "aws_route53_zone" "default" {
  count = "${local.postgres_cluster_enabled ? 1 : 0}"
  name  = "${var.zone_name == "" ? var.kops_cluster_name : var.zone_name}"
}

resource "random_pet" "postgres_db_name" {
  count     = "${local.postgres_cluster_enabled && length(var.postgres_db_name) == 0 ? 1 : 0}"
  separator = "_"
}

resource "random_string" "postgres_admin_user" {
  count   = "${local.postgres_cluster_enabled && length(var.postgres_admin_user) == 0 ? 1 : 0}"
  length  = 8
  special = false
  number  = false
}

resource "random_string" "postgres_admin_password" {
  count   = "${local.postgres_cluster_enabled && length(var.postgres_admin_password) == 0 ? 1 : 0}"
  length  = 16
  special = true
}

module "aurora_postgres" {
  source                              = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.15.0"
  enabled                             = "${var.postgres_cluster_enabled}"
  namespace                           = "${var.namespace}"
  stage                               = "${var.stage}"
  name                                = "${var.postgres_name}"
  engine                              = "aurora-postgresql"
  cluster_family                      = "aurora-postgresql9.6"
  instance_type                       = "${var.postgres_instance_type}"
  cluster_size                        = "${var.postgres_cluster_size}"
  admin_user                          = "${local.postgres_admin_user}"
  admin_password                      = "${local.postgres_admin_password}"
  db_name                             = "${local.postgres_db_name}"
  db_port                             = "5432"
  vpc_id                              = "${module.kops_metadata_vpc.vpc_id}"
  subnets                             = ["${module.kops_metadata_vpc.private_subnet_ids}"]
  zone_id                             = "${local.zone_id}"
  security_groups                     = ["${module.kops_metadata_vpc.nodes_security_group_id}"]
  iam_database_authentication_enabled = "${var.postgres_iam_database_authentication_enabled}"
  cluster_dns_name                    = "${var.postgres_cluster_dns_name}"
  reader_dns_name                     = "${var.postgres_reader_dns_name}"
}

data "aws_kms_key" "chamber_kms_key" {
  count  = "${local.postgres_cluster_enabled ? 1 : 0}"
  key_id = "${local.kms_key_id}"
}

resource "aws_ssm_parameter" "aurora_postgres_database_name" {
  count       = "${local.postgres_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_postgres_database_name")}"
  value       = "${join("", module.aurora_postgres.*.name)}"
  description = "Aurora Postgres Database Name"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "aurora_postgres_master_username" {
  count       = "${local.postgres_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_postgres_master_username")}"
  value       = "${join("", module.aurora_postgres.*.user)}"
  description = "Aurora Postgres Username for the master DB user"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "aurora_postgres_master_password" {
  count       = "${local.postgres_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_postgres_master_password")}"
  value       = "${join("", module.aurora_postgres.*.password)}"
  description = "Aurora Postgres Password for the master DB user"
  type        = "SecureString"
  key_id      = "${join("", data.aws_kms_key.chamber_kms_key.*.id)}"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "aurora_postgres_master_hostname" {
  count       = "${local.postgres_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_postgres_master_hostname")}"
  value       = "${join("", module.aurora_postgres.*.master_host)}"
  description = "Aurora Postgres DB Master hostname"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "aurora_postgres_replicas_hostname" {
  count       = "${local.postgres_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_postgres_replicas_hostname")}"
  value       = "${join("", module.aurora_postgres.*.replicas_host)}"
  description = "Aurora Postgres DB Replicas hostname"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "aurora_postgres_cluster_name" {
  count       = "${local.postgres_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_postgres_cluster_name")}"
  value       = "${join("", module.aurora_postgres.*.cluster_name)}"
  description = "Aurora Postgres DB Cluster Identifier"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}
