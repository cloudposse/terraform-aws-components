variable "postgres_name" {
  type        = string
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "postgres"
}

# Don't use `admin` 
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "postgres_admin_user" {
  type        = string
  description = "Postgres admin user name"
  default     = "sentry"
}

# Must be longer than 8 chars
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "postgres_admin_password" {
  type        = string
  description = "Postgres password for the admin user"
  default     = ""
}

variable "postgres_db_name" {
  type        = string
  description = "Postgres database name"
  default     = "sentry"
}

variable "aurora_postgres_engine_version" {
  type        = string
  description = "Database Engine Version for Aurora PostgeSQL"
  default     = "9.6.12"
}

variable "aurora_postgres_cluster_family" {
  type        = string
  description = "Database Engine Version for Aurora PostgeSQL"
  default     = "9.6.12"
}

# db.r4.large is the smallest instance type supported by Aurora Postgres 9.6
# Postgres 10.6 and later can use db.r5.large
# Postgres 10.7 and later can use db.t3.medium
# https://aws.amazon.com/rds/aurora/pricing
variable "postgres_instance_type" {
  type        = string
  default     = "db.r4.large"
  description = "EC2 instance type for Postgres cluster"
}

variable "postgres_cluster_size" {
  type        = number
  default     = 2
  description = "Postgres cluster size"
}

variable "postgres_autoscaling_enabled" {
  type        = bool
  default     = false
  description = "Set true to enable the database cluster autoscaler"
}

variable "postgres_autoscaling_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of Postgres instances to be maintained by the autoscaler"
}

variable "postgres_autoscaling_max_capacity" {
  type        = number
  default     = 6
  description = "Maximum number of Postgres instances to be maintained by the autoscaler"
}

variable "postgres_cluster_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "postgres_iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled."
}

resource "random_string" "postgres_admin_password" {
  count   = local.postgres_cluster_enabled ? 1 : 0
  length  = 26
  special = true
}

locals {
  # Some of these locals used to be computed. Keep them as local just for consistency,
  # even though now they are just copies of variables.
  postgres_cluster_enabled = var.postgres_cluster_enabled
  postgres_db_name         = var.postgres_db_name
  postgres_admin_user      = length(var.postgres_admin_user) > 0 ? var.postgres_admin_user : "sentry"
  postgres_admin_password  = length(var.postgres_admin_password) > 0 ? var.postgres_admin_password : join("", random_string.postgres_admin_password.*.result)
}

module "aurora_postgres" {
  source           = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.16.0"
  namespace        = var.namespace
  stage            = var.stage
  name             = var.postgres_name
  attributes       = ["sentry"]
  engine           = "aurora-postgresql"
  cluster_family   = "aurora-postgresql9.6"
  engine_version   = var.aurora_postgres_engine_version
  instance_type    = var.postgres_instance_type
  cluster_size     = var.postgres_cluster_size
  admin_user       = local.postgres_admin_user
  admin_password   = local.postgres_admin_password
  db_name          = local.postgres_db_name
  db_port          = "5432"
  vpc_id           = module.kops_metadata.vpc_id
  subnets          = module.kops_metadata.private_subnet_ids
  zone_id          = local.zone_id
  cluster_dns_name = "master.postgres-sentry"
  reader_dns_name  = "replicas.postgres-sentry"
  security_groups  = [module.kops_metadata.nodes_security_group_id]
  enabled          = var.postgres_cluster_enabled

  iam_database_authentication_enabled = var.postgres_iam_database_authentication_enabled
}

resource "aws_ssm_parameter" "aurora_postgres_database_name" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_database")
  value       = module.aurora_postgres.database_name
  description = "Aurora Postgres Database Name for Sentry"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "aurora_postgres_master_username" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_user")
  value       = module.aurora_postgres.master_username
  description = "Aurora Postgres Username for Sentry's master DB user"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "aurora_postgres_master_password" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_password")
  value       = local.postgres_admin_password
  description = "Aurora Postgres Password for Sentry's master DB user"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "aurora_postgres_master_hostname" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_host")
  value       = module.aurora_postgres.master_host
  description = "Aurora Postgres DB Master hostname"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "aurora_postgres_replicas_hostname" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_replicas_hostname")
  value       = module.aurora_postgres.replicas_host
  description = "Aurora Postgres DB Replicas hostname"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "aurora_postgres_cluster_name" {
  count       = local.postgres_cluster_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_cluster_name")
  value       = module.aurora_postgres.cluster_identifier
  description = "Aurora Postgres DB Cluster Identifier"
  type        = "String"
  overwrite   = true
}

output "aurora_postgres_database_name" {
  value       = module.aurora_postgres.database_name
  description = "Aurora Postgres Database name"
}

output "aurora_postgres_master_username" {
  value       = module.aurora_postgres.master_username
  description = "Aurora Postgres Username for the master DB user"
}

output "aurora_postgres_master_hostname" {
  value       = module.aurora_postgres.master_host
  description = "Aurora Postgres DB Master hostname"
}

output "aurora_postgres_replicas_hostname" {
  value       = module.aurora_postgres.replicas_host
  description = "Aurora Postgres Replicas hostname"
}

output "aurora_postgres_cluster_name" {
  value       = module.aurora_postgres.cluster_identifier
  description = "Aurora Postgres Cluster Identifier"
}
