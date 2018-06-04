# Don't use `admin`
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "POSTGRES_ADMIN_NAME" {
  type        = "string"
  description = "Postgres admin user name"
}

# Must be longer than 8 chars
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "POSTGRES_ADMIN_PASSWORD" {
  type        = "string"
  description = "Postgres password for the admin user"
}

variable "POSTGRES_DB_NAME" {
  type        = "string"
  description = "Postgres database name"
}

# db.r4.large is the smallest instance type supported by Aurora Postgres
# https://aws.amazon.com/rds/aurora/pricing
variable "POSTGRES_INSTANCE_TYPE" {
  type        = "string"
  default     = "db.r4.large"
  description = "EC2 instance type for Postgres cluster"
}

variable "POSTGRES_CLUSTER_SIZE" {
  type        = "string"
  default     = "2"
  description = "Postgres cluster size"
}

variable "POSTGRES_CLUSTER_ENABLED" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

module "aurora_postgres" {
  source             = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.3.5"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "postgres"
  engine             = "aurora-postgresql"
  cluster_family     = "aurora-postgresql9.6"
  instance_type      = "${var.POSTGRES_INSTANCE_TYPE}"
  cluster_size       = "${var.POSTGRES_CLUSTER_SIZE}"
  admin_user         = "${var.POSTGRES_ADMIN_NAME}"
  admin_password     = "${var.POSTGRES_ADMIN_PASSWORD}"
  db_name            = "${var.POSTGRES_DB_NAME}"
  db_port            = "5432"
  vpc_id             = "${module.vpc.vpc_id}"
  availability_zones = ["${data.aws_availability_zones.available}"]
  subnets            = ["${module.subnets.private_subnet_ids}"]
  zone_id            = "${var.zone_id}"
  security_groups    = ["${module.kops_metadata.nodes_security_group_id}"]
  enabled            = "${var.POSTGRES_CLUSTER_ENABLED}"
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
