# https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html

variable "mysql_name" {
  type        = string
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "mysql"
}

variable "mysql_admin_user" {
  type        = string
  description = "MySQL admin user name"
  default     = ""
}

variable "mysql_admin_password" {
  type        = string
  description = "MySQL password for the admin user"
  default     = ""
}

variable "mysql_db_name" {
  type        = string
  description = "MySQL database name"
  default     = "grafana"
}

variable "mysql_cluster_enabled" {
  type        = bool
  default     = false
  description = "Set to false to prevent the module from creating any resources"
}

variable "mysql_cluster_publicly_accessible" {
  type        = bool
  default     = false
  description = "Specifies the accessibility options for the DB instance. A value of true specifies an Internet-facing instance with a publicly resolvable DNS name, which resolves to a public IP address. A value of false specifies an internal instance with a DNS name that resolves to a private IP address"
}

variable "mysql_cluster_allowed_cidr_blocks" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Comma separated string list of CIDR blocks allowed to access the cluster, or SSM parameter key for it"
}

variable "mysql_storage_encrypted" {
  type        = bool
  default     = true
  description = "Set to true to keep the database contents encrypted"
}

variable "mysql_kms_key_id" {
  type        = string
  default     = "alias/aws/rds"
  description = "KMS key ID, ARN, or alias to use for encrypting MySQL database"
}

variable "mysql_deletion_protection" {
  type        = bool
  default     = true
  description = "Set to true to protect the database from deletion"
}

variable "mysql_skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
}

data "aws_route53_zone" "default" {
  count = length(var.dns_zone_name) > 0 ? 1 : 0
  name  = var.dns_zone_name
}

resource "random_string" "mysql_admin_user" {
  count   = var.mysql_cluster_enabled && length(var.mysql_admin_user) == 0 ? 1 : 0
  length  = 8
  number  = false
  special = false
}

resource "random_string" "mysql_admin_password" {
  count   = var.mysql_cluster_enabled && length(var.mysql_admin_password) == 0 ? 1 : 0
  length  = 33
  special = false
}

#  "Read SSM parameter to get allowed CIDR blocks"
data "aws_ssm_parameter" "allowed_cidr_blocks" {
  # The data source will throw an error if it cannot find the parameter,
  # so do not reference it unless it is neeeded.
  count = local.allowed_cidr_blocks_use_ssm ? 1 : 0

  # name = substr(mysql_cluster_allowed_cidr_blocks, 0, 1) == "/" ? mysql_cluster_allowed_cidr_blocks : "/aws/service/global-infrastructure/version"
  name = var.mysql_cluster_allowed_cidr_blocks
}

#  "Read SSM parameter to get allowed VPC ID"
data "aws_ssm_parameter" "vpc_id" {
  # The data source will throw an error if it cannot find the parameter,
  # so do not reference it unless it is neeeded.
  count = local.vpc_id_use_ssm ? 1 : 0
  name  = var.vpc_id
}

#  "Read SSM parameter to get allowed VPC subnet IDs"
data "aws_ssm_parameter" "vpc_subnet_ids" {
  # The data source will throw an error if it cannot find the parameter,
  # so do not reference it unless it is neeeded.
  count = local.vpc_subnet_ids_use_ssm ? 1 : 0
  name  = var.vpc_subnet_ids
}

locals {
  chamber_service = var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service
  dns_zone_id     = length(var.dns_zone_name) > 0 ? join("", data.aws_route53_zone.default.*.zone_id) : ""

  mysql_admin_user     = length(var.mysql_admin_user) > 0 ? var.mysql_admin_user : join("", random_string.mysql_admin_user.*.result)
  mysql_admin_password = length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : join("", random_string.mysql_admin_password.*.result)
  mysql_db_name        = var.mysql_db_name

  allowed_cidr_blocks_use_ssm = substr(var.mysql_cluster_allowed_cidr_blocks, 0, 1) == "/" && var.mysql_cluster_enabled
  vpc_id_use_ssm              = substr(var.vpc_id, 0, 1) == "/" && var.mysql_cluster_enabled
  vpc_subnet_ids_use_ssm      = substr(var.vpc_subnet_ids, 0, 1) == "/" && var.mysql_cluster_enabled

  allowed_cidr_blocks_string = local.allowed_cidr_blocks_use_ssm ? join("", data.aws_ssm_parameter.allowed_cidr_blocks.*.value) : var.mysql_cluster_allowed_cidr_blocks
  vpc_subnet_ids_string      = local.vpc_subnet_ids_use_ssm ? join("", data.aws_ssm_parameter.vpc_subnet_ids.*.value) : var.vpc_subnet_ids

  allowed_cidr_blocks = split(",", local.allowed_cidr_blocks_string)

  vpc_id         = local.vpc_id_use_ssm ? join("", data.aws_ssm_parameter.vpc_id.*.value) : var.vpc_id
  vpc_subnet_ids = split(",", local.vpc_subnet_ids_string)
}

data "aws_kms_key" "mysql" {
  key_id = var.mysql_kms_key_id
}

module "aurora_mysql" {
  source           = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.16.0"
  enabled          = var.mysql_cluster_enabled
  namespace        = var.namespace
  stage            = var.stage
  name             = var.mysql_name
  attributes       = ["grafana"]
  cluster_dns_name = "mysql-grafana"
  engine           = "aurora"
  engine_version   = "5.6.10a"
  engine_mode      = "serverless"
  cluster_family   = "aurora5.6"
  cluster_size     = 0
  admin_user       = local.mysql_admin_user
  admin_password   = local.mysql_admin_password
  db_name          = local.mysql_db_name
  db_port          = 3306
  vpc_id           = local.vpc_id
  subnets          = local.vpc_subnet_ids
  zone_id          = var.mysql_cluster_publicly_accessible ? local.dns_zone_id : ""

  storage_encrypted   = var.mysql_storage_encrypted
  kms_key_arn         = var.mysql_storage_encrypted ? data.aws_kms_key.mysql.arn : ""
  deletion_protection = var.mysql_deletion_protection
  skip_final_snapshot = var.mysql_skip_final_snapshot
  publicly_accessible = var.mysql_cluster_publicly_accessible
  allowed_cidr_blocks = local.allowed_cidr_blocks

  scaling_configuration = [
    {
      auto_pause               = false
      max_capacity             = 16
      min_capacity             = 1
      seconds_until_auto_pause = 86400
    },
  ]
}

resource "aws_ssm_parameter" "aurora_mysql_database_name" {
  count       = var.mysql_cluster_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "grafana_db_name")
  value       = module.aurora_mysql.database_name
  description = "Aurora MySQL Database Name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_username" {
  count       = var.mysql_cluster_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "grafana_db_user")
  value       = module.aurora_mysql.master_username
  description = "Aurora MySQL Username for the master DB user"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_password" {
  count       = var.mysql_cluster_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "grafana_db_password")
  value       = local.mysql_admin_password
  description = "Aurora MySQL Password for the master DB user"
  type        = "SecureString"
  overwrite   = "true"
  key_id      = var.chamber_kms_key_id
}

resource "aws_ssm_parameter" "aurora_mysql_endpoint_hostname" {
  count       = var.mysql_cluster_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "grafana_db_host")
  value       = module.aurora_mysql.endpoint
  description = "Aurora MySQL DB endpoint DNS name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_port" {
  count       = var.mysql_cluster_enabled ? 1 : 0
  name        = format(var.chamber_parameter_name_pattern, local.chamber_service, "grafana_db_port")
  value       = "3306"
  description = "Aurora MySQL DB endpoint port"
  type        = "String"
  overwrite   = "true"
}

output "aurora_mysql_database_name" {
  value       = module.aurora_mysql.database_name
  description = "Aurora MySQL Database name"
}

output "aurora_mysql_master_username" {
  value       = module.aurora_mysql.master_username
  description = "Aurora MySQL Username for the master DB user"
}

output "aurora_mysql_endpoint" {
  value       = module.aurora_mysql.endpoint
  description = "Aurora MySQL DB endpoint"
}

output "aurora_mysql_master_hostname" {
  value       = module.aurora_mysql.master_host
  description = "Aurora MySQL DB Master hostname"
}

output "aurora_mysql_replicas_hostname" {
  value       = module.aurora_mysql.replicas_host
  description = "Aurora MySQL Replicas hostname"
}

output "aurora_mysql_cluster_name" {
  value       = module.aurora_mysql.cluster_identifier
  description = "Aurora MySQL Cluster Identifier"
}
