variable "rds_cluster_replica_name" {
  type        = "string"
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "postgres"
}

# db.r4.large is the smallest instance type supported by Aurora Postgres
# https://aws.amazon.com/rds/aurora/pricing
variable "rds_cluster_replica_instance_type" {
  type        = "string"
  default     = "db.r4.large"
  description = "EC2 instance type for Postgres cluster"
}

variable "rds_cluster_replica_cluster_size" {
  type        = "string"
  default     = "2"
  description = "Postgres cluster size"
}

variable "rds_cluster_replica_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

variable "rds_cluster_replica_cluster_identifier" {
  type        = "string"
  description = "The cluster identifier"
  default     = ""
}

locals {
  rds_cluster_replica_enabled = "${var.rds_cluster_replica_enabled == "true"}"
}

module "rds_cluster_replica" {
  source             = "git::https://github.com/cloudposse/terraform-aws-rds-cluster-instance-group.git?ref=tags/0.1.0"
  enabled            = "${var.rds_cluster_replica_enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.rds_cluster_replica_name}"
  cluster_identifier = "${var.rds_cluster_replica_cluster_identifier}"
  cluster_family     = "aurora-postgresql9.6"
  engine             = "aurora-postgresql"
  instance_type      = "${var.rds_cluster_replica_instance_type}"
  cluster_size       = "${var.rds_cluster_replica_cluster_size}"
  db_port            = "5432"
  vpc_id             = "${module.vpc.vpc_id}"
  subnets            = ["${module.subnets.private_subnet_ids}"]
  zone_id            = "${local.zone_id}"
  security_groups    = ["${module.kops_metadata.nodes_security_group_id}"]
}

resource "aws_ssm_parameter" "rds_cluster_replica_hostname" {
  count       = "${local.rds_cluster_replica_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "rds_cluster_replica_hostname")}"
  value       = "${module.rds_cluster_replica.hostname}"
  description = "RDS Cluster replica hostname"
  type        = "String"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "rds_cluster_replica_endpoint" {
  count       = "${local.rds_cluster_replica_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "rds_cluster_replica_endpoint")}"
  value       = "${module.rds_cluster_replica.endpoint}"
  description = "RDS Cluster Replicas hostname"
  type        = "String"
  overwrite   = "true"
}

output "rds_cluster_replica_hostname" {
  value       = "${module.rds_cluster_replica.hostname}"
  description = "RDS Cluster replica hostname"
}

output "rds_cluster_replica_endpoint" {
  value       = "${module.rds_cluster_replica.endpoint}"
  description = "RDS Cluster replica endpoint"
}
