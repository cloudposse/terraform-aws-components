variable "postgres_name" {
  type        = "string"
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "postgres"
}

# Don't use `admin`
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "postgres_admin_user" {
  type        = "string"
  description = "Postgres admin user name"
  default     = ""
}

# Must be longer than 8 chars
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "postgres_admin_password" {
  type        = "string"
  description = "Postgres password for the admin user"
  default     = ""
}

variable "postgres_db_name" {
  type        = "string"
  description = "Postgres database name"
  default     = ""
}

# db.r4.large is the smallest instance type supported by Aurora Postgres
# https://aws.amazon.com/rds/aurora/pricing
variable "postgres_instance_type" {
  type        = "string"
  default     = "db.r4.large"
  description = "EC2 instance type for Postgres cluster"
}

variable "postgres_cluster_size" {
  type        = "string"
  default     = "2"
  description = "Postgres cluster size"
}

variable "postgres_cluster_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

resource "random_pet" "postgres_db_name" {
  separator = "_"
}

resource "random_string" "postgres_admin_user" {
  length  = 8
  special = false
}

resource "random_string" "postgres_admin_password" {
  length           = 16
  special          = true
  override_special = "/@\" "
}

locals {
  postgres_admin_user     = "${length(var.postgres_admin_user) > 0 ? var.postgres_admin_user : random_string.postgres_admin_user.result}"
  postgres_admin_password = "${length(var.postgres_admin_password) > 0 ? var.postgres_admin_password : random_string.postgres_admin_password.result}"
  postgres_db_name        = "${random_pet.postgres_db_name.id}"
}

module "aurora_postgres" {
  source          = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=fix-outputs"
  namespace       = "${var.namespace}"
  stage           = "${var.stage}"
  name            = "${var.postgres_name}"
  engine          = "aurora-postgresql"
  cluster_family  = "aurora-postgresql9.6"
  instance_type   = "${var.postgres_instance_type}"
  cluster_size    = "${var.postgres_cluster_size}"
  admin_user      = "${local.postgres_admin_user}"
  admin_password  = "${local.postgres_admin_password}"
  db_name         = "${local.postgres_db_name}"
  db_port         = "5432"
  vpc_id          = "${module.vpc.vpc_id}"
  subnets         = ["${module.subnets.private_subnet_ids}"]
  zone_id         = "${local.zone_id}"
  security_groups = ["${module.kops_metadata.nodes_security_group_id}"]
  enabled         = "${var.postgres_cluster_enabled}"
}

output "aurora_postgres_database_name" {
  value       = "${module.aurora_postgres.name}"
  description = "Database name"
}

output "aurora_postgres_master_username" {
  value       = "${module.aurora_postgres.user}"
  description = "Username for the master DB user"
}

output "aurora_postgres_master_hostname" {
  value       = "${module.aurora_postgres.master_host}"
  description = "DB Master hostname"
}

output "aurora_postgres_replicas_hostname" {
  value       = "${module.aurora_postgres.replicas_host}"
  description = "Replicas hostname"
}

output "aurora_postgres_cluster_name" {
  value       = "${module.aurora_postgres.cluster_name}"
  description = "Cluster Identifier"
}
