# https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html

variable "mysql_name" {
  type        = "string"
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "mysql"
}

variable "mysql_admin_user" {
  type        = "string"
  description = "MySQL admin user name"
  default     = ""
}

variable "mysql_admin_password" {
  type        = "string"
  description = "MySQL password for the admin user"
  default     = ""
}

variable "mysql_db_name" {
  type        = "string"
  description = "MySQL database name"
  default     = ""
}

# https://aws.amazon.com/rds/aurora/pricing
variable "mysql_instance_type" {
  type        = "string"
  default     = "db.t3.small"
  description = "EC2 instance type for Aurora MySQL cluster"
}

variable "mysql_cluster_size" {
  type        = "string"
  default     = "2"
  description = "MySQL cluster size"
}

variable "mysql_cluster_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

variable "mysql_cluster_publicly_accessible" {
  default     = true
  description = "Specifies the accessibility options for the DB instance. A value of true specifies an Internet-facing instance with a publicly resolvable DNS name, which resolves to a public IP address. A value of false specifies an internal instance with a DNS name that resolves to a private IP address"
}

variable "mysql_cluster_allowed_cidr_blocks" {
  type        = "string"
  default     = "0.0.0.0/0"
  description = "Comma separated string list of CIDR blocks allowed to access the cluster, or SSM parameter key for it"
}

variable "mysql_storage_encrypted" {
  type        = "string"
  default     = "false"
  description = "Set to true to keep the database contents encrypted"
}

variable "mysql_kms_key_id" {
  type        = "string"
  default     = "alias/aws/rds"
  description = "KMS key ID, ARN, or alias to use for encrypting MySQL database"
}

variable "mysql_deletion_protection" {
  type        = "string"
  default     = "true"
  description = "Set to true to protect the database from deletion"
}

variable "mysql_skip_final_snapshot" {
  type        = "string"
  default     = "false"
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
}

variable "vpc_id" {
  type        = "string"
  description = "The AWS ID of the VPC to create the cluster in, or SSM parameter key for it"
}

variable "vpc_subnet_ids" {
  type        = "string"
  description = "Comma separated string list of AWS Subnet IDs in which to place the database, or SSM parameter key for it"
}

resource "random_pet" "mysql_db_name" {
  count     = "${local.mysql_cluster_enabled && length(var.mysql_db_name) == 0 ? 1 : 0}"
  separator = "_"
}

resource "random_string" "mysql_admin_user" {
  count   = "${local.mysql_cluster_enabled && length(var.mysql_admin_user) == 0 ? 1 : 0}"
  length  = 8
  number  = false
  special = false
}

resource "random_string" "mysql_admin_password" {
  count   = "${local.mysql_cluster_enabled && length(var.mysql_admin_password) == 0 ? 1 : 0}"
  length  = 33
  special = false
}

#  "Read SSM parameter to get allowed CIDR blocks"
data "aws_ssm_parameter" "allowed_cidr_blocks" {
  count = "${local.allowed_cidr_blocks_use_ssm ? 1 : 0}"

  # The data source will throw an error if it cannot find the parameter,
  # name = "${substr(mysql_cluster_allowed_cidr_blocks, 0, 1) == "/" ? mysql_cluster_allowed_cidr_blocks : "/aws/service/global-infrastructure/version"}"
  name = "${var.mysql_cluster_allowed_cidr_blocks}"
}

#  "Read SSM parameter to get allowed VPC ID"
data "aws_ssm_parameter" "vpc_id" {
  count = "${local.vpc_id_use_ssm ? 1 : 0}"

  # The data source will throw an error if it cannot find the parameter,
  # name = "${substr(mysql_cluster_allowed_cidr_blocks, 0, 1) == "/" ? mysql_cluster_allowed_cidr_blocks : "/aws/service/global-infrastructure/version"}"
  name = "${var.vpc_id}"
}

#  "Read SSM parameter to get allowed VPC subnet IDs"
data "aws_ssm_parameter" "vpc_subnet_ids" {
  count = "${local.vpc_subnet_ids_use_ssm ? 1 : 0}"

  # The data source will throw an error if it cannot find the parameter,
  # name = "${substr(mysql_cluster_allowed_cidr_blocks, 0, 1) == "/" ? mysql_cluster_allowed_cidr_blocks : "/aws/service/global-infrastructure/version"}"
  name = "${var.vpc_subnet_ids}"
}

locals {
  mysql_cluster_enabled = "${var.mysql_cluster_enabled == "true"}"
  mysql_admin_user      = "${length(var.mysql_admin_user) > 0 ? var.mysql_admin_user : join("", random_string.mysql_admin_user.*.result)}"
  mysql_admin_password  = "${length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : join("", random_string.mysql_admin_password.*.result)}"
  mysql_db_name         = "${length(var.mysql_db_name) > 0 ? var.mysql_db_name : join("", random_pet.mysql_db_name.*.id)}"

  allowed_cidr_blocks_use_ssm = "${substr(var.mysql_cluster_allowed_cidr_blocks, 0, 1) == "/" && local.mysql_cluster_enabled}"
  vpc_id_use_ssm              = "${substr(var.vpc_id, 0, 1) == "/" && local.mysql_cluster_enabled}"
  vpc_subnet_ids_use_ssm      = "${substr(var.vpc_subnet_ids, 0, 1) == "/" && local.mysql_cluster_enabled}"

  allowed_cidr_blocks_string = "${local.allowed_cidr_blocks_use_ssm ? join("", data.aws_ssm_parameter.allowed_cidr_blocks.*.value) : var.mysql_cluster_allowed_cidr_blocks}"
  vpc_subnet_ids_string      = "${local.vpc_subnet_ids_use_ssm ? join("", data.aws_ssm_parameter.vpc_subnet_ids.*.value) : var.vpc_subnet_ids}"

  allowed_cidr_blocks = [
    "${split(",", local.allowed_cidr_blocks_string)}",
  ]

  vpc_id = "${local.vpc_id_use_ssm ? join("", data.aws_ssm_parameter.vpc_id.*.value) : var.vpc_id}"

  vpc_subnet_ids = [
    "${split(",", local.vpc_subnet_ids_string)}",
  ]
}

data "aws_kms_key" "mysql" {
  key_id = "${var.mysql_kms_key_id}"
}

module "aurora_mysql" {
  source         = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.15.0"
  namespace      = "${var.namespace}"
  stage          = "${var.stage}"
  name           = "${var.mysql_name}"
  attributes     = ["keycloak"]
  engine         = "aurora-mysql"
  cluster_family = "aurora-mysql5.7"
  instance_type  = "${var.mysql_instance_type}"
  cluster_size   = "${var.mysql_cluster_size}"
  admin_user     = "${local.mysql_admin_user}"
  admin_password = "${local.mysql_admin_password}"
  db_name        = "${local.mysql_db_name}"
  db_port        = "3306"
  vpc_id         = "${local.vpc_id}"
  subnets        = "${local.vpc_subnet_ids}"
  zone_id        = "${local.dns_zone_id}"
  enabled        = "${var.mysql_cluster_enabled}"

  storage_encrypted   = "${var.mysql_storage_encrypted}"
  kms_key_arn         = "${var.mysql_storage_encrypted ? data.aws_kms_key.mysql.arn : ""}"
  deletion_protection = "${var.mysql_deletion_protection}"
  skip_final_snapshot = "${var.mysql_skip_final_snapshot}"
  publicly_accessible = "${var.mysql_cluster_publicly_accessible}"
  allowed_cidr_blocks = "${local.allowed_cidr_blocks}"
}

resource "aws_ssm_parameter" "aurora_mysql_database_name" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_db_name")}"
  value       = "${module.aurora_mysql.name}"
  description = "Aurora MySQL Database Name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_username" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_db_user")}"
  value       = "${module.aurora_mysql.user}"
  description = "Aurora MySQL Username for the master DB user"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_password" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_db_password")}"
  value       = "${local.mysql_admin_password}"
  description = "Aurora MySQL Password for the master DB user"
  type        = "SecureString"
  overwrite   = "true"
  key_id      = "${var.chamber_kms_key_id}"
}

resource "aws_ssm_parameter" "aurora_mysql_master_hostname" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_db_host")}"
  value       = "${module.aurora_mysql.master_host}"
  description = "Aurora MySQL DB Master hostname"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_port" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_db_port")}"
  value       = "3306"
  description = "Aurora MySQL DB Master hostname"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_replicas_hostname" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_aurora_mysql_replicas_hostname")}"
  value       = "${module.aurora_mysql.replicas_host}"
  description = "Aurora MySQL DB Replicas hostname"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_cluster_name" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name_pattern, local.chamber_service, "keycloak_aurora_mysql_cluster_name")}"
  value       = "${module.aurora_mysql.cluster_name}"
  description = "Aurora MySQL DB Cluster Identifier"
  type        = "String"
  overwrite   = "true"
}

output "aurora_mysql_database_name" {
  value       = "${module.aurora_mysql.name}"
  description = "Aurora MySQL Database name"
}

output "aurora_mysql_master_username" {
  value       = "${module.aurora_mysql.user}"
  description = "Aurora MySQL Username for the master DB user"
}

output "aurora_mysql_master_hostname" {
  value       = "${module.aurora_mysql.master_host}"
  description = "Aurora MySQL DB Master hostname"
}

output "aurora_mysql_replicas_hostname" {
  value       = "${module.aurora_mysql.replicas_host}"
  description = "Aurora MySQL Replicas hostname"
}

output "aurora_mysql_cluster_name" {
  value       = "${module.aurora_mysql.cluster_name}"
  description = "Aurora MySQL Cluster Identifier"
}
