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
  default     = "db.t2.small"
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
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access the cluster"
}

resource "random_pet" "mysql_db_name" {
  count     = "${local.mysql_cluster_enabled ? 1 : 0}"
  separator = "_"
}

resource "random_string" "mysql_admin_user" {
  count   = "${local.mysql_cluster_enabled ? 1 : 0}"
  length  = 8
  number  = false
  special = false
}

resource "random_string" "mysql_admin_password" {
  count   = "${local.mysql_cluster_enabled ? 1 : 0}"
  length  = 16
  special = true
}

locals {
  mysql_cluster_enabled = "${var.mysql_cluster_enabled == "true"}"
  mysql_admin_user      = "${length(var.mysql_admin_user) > 0 ? var.mysql_admin_user : join("", random_string.mysql_admin_user.*.result)}"
  mysql_admin_password  = "${length(var.mysql_admin_password) > 0 ? var.mysql_admin_password : join("", random_string.mysql_admin_password.*.result)}"
  mysql_db_name         = "${join("", random_pet.mysql_db_name.*.id)}"
}

module "aurora_mysql" {
  source         = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.8.0"
  namespace      = "${var.namespace}"
  stage          = "${var.stage}"
  name           = "${var.mysql_name}"
  engine         = "aurora-mysql"
  cluster_family = "aurora-mysql5.7"
  instance_type  = "${var.mysql_instance_type}"
  cluster_size   = "${var.mysql_cluster_size}"
  admin_user     = "${local.mysql_admin_user}"
  admin_password = "${local.mysql_admin_password}"
  db_name        = "${local.mysql_db_name}"
  db_port        = "3306"
  vpc_id         = "${module.vpc.vpc_id}"

  # Use module.subnets.private_subnet_ids if the cluster does not need to be publicly accessible
  subnets             = ["${module.subnets.public_subnet_ids}"]
  zone_id             = "${local.zone_id}"
  enabled             = "${var.mysql_cluster_enabled}"
  publicly_accessible = "${var.mysql_cluster_publicly_accessible}"
  allowed_cidr_blocks = "${var.mysql_cluster_allowed_cidr_blocks}"
}

resource "aws_ssm_parameter" "aurora_mysql_database_name" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_mysql_database_name")}"
  value       = "${module.aurora_mysql.name}"
  description = "Aurora MySQL Database Name"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_username" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_mysql_master_username")}"
  value       = "${module.aurora_mysql.user}"
  description = "Aurora MySQL Username for the master DB user"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_password" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_mysql_master_password")}"
  value       = "${module.aurora_mysql.password}"
  description = "Aurora MySQL Password for the master DB user"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_master_hostname" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_mysql_master_hostname")}"
  value       = "${module.aurora_mysql.master_host}"
  description = "Aurora MySQL DB Master hostname"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_replicas_hostname" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_mysql_replicas_hostname")}"
  value       = "${module.aurora_mysql.replicas_host}"
  description = "Aurora MySQL DB Replicas hostname"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "aurora_mysql_cluster_name" {
  count       = "${local.mysql_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "aurora_mysql_cluster_name")}"
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
