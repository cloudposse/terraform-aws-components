variable "postgres_name" {
  type        = "string"
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "postgres"
}

# Don't use `admin`
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "postgres_admin_name" {
  type        = "string"
  description = "Postgres admin user name"
}

# Must be longer than 8 chars
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "postgres_admin_password" {
  type        = "string"
  description = "Postgres password for the admin user"
}

variable "postgres_db_name" {
  type        = "string"
  description = "Postgres database name"
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

module "aurora_postgres" {
  source          = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.7.0"
  namespace       = "${var.namespace}"
  stage           = "${var.stage}"
  name            = "${var.postgres_name}"
  engine          = "aurora-postgresql"
  cluster_family  = "aurora-postgresql9.6"
  instance_type   = "${var.postgres_instance_type}"
  cluster_size    = "${var.postgres_cluster_size}"
  admin_user      = "${var.postgres_admin_name}"
  admin_password  = "${var.postgres_admin_password}"
  db_name         = "${var.postgres_db_name}"
  db_port         = "5432"
  vpc_id          = "${module.vpc.vpc_id}"
  subnets         = ["${module.subnets.private_subnet_ids}"]
  zone_id         = "${var.zone_id}"
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
