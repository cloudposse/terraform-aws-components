# Don't use `admin`
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "RDS_ADMIN_NAME" {
  type        = "string"
  description = "RDS DB admin user name"
}

# Must be longer than 8 chars
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "RDS_ADMIN_PASSWORD" {
  type        = "string"
  description = "RDS DB password for the admin user"
}

variable "RDS_DB_NAME" {
  type        = "string"
  description = "RDS DB database name"
}

# db.t2.micro is free tier
# https://aws.amazon.com/rds/free
variable "RDS_INSTANCE_TYPE" {
  type        = "string"
  default     = "db.t2.micro"
  description = "EC2 instance type for RDS DB"
}

variable "RDS_CLUSTER_ENABLED" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "RDS_SNAPSHOT" {
  type        = "string"
  default     = ""
  description = "Restore snapshots"
}

variable "RDS_PARAMETER_GROUP_NAME" {
  type        = "string"
  default     = ""
  description = "Existed paramater group name to use"
}

module "rds" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-rds.git?ref=tags/0.4.0"
  namespace                   = "${var.namespace}"
  stage                       = "${var.stage}"
  name                        = "rds"
  dns_zone_id                 = "${var.zone_id}"
  host_name                   = "rds"
  security_group_ids          = ["${module.kops_metadata.nodes_security_group_id}"]
  database_name               = "${var.RDS_DB_NAME}"
  database_user               = "${var.RDS_ADMIN_NAME}"
  database_password           = "${var.RDS_ADMIN_PASSWORD}"
  database_port               = 3306
  multi_az                    = "false"
  storage_type                = "gp2"
  allocated_storage           = "20"
  storage_encrypted           = "false"
  engine                      = "mariadb"
  engine_version              = "10.1.19"
  instance_class              = "${var.RDS_INSTANCE_TYPE}"
  db_parameter_group          = "mariadb10.1"
  parameter_group_name        = "${var.RDS_PARAMETER_GROUP_NAME}"
  publicly_accessible         = "false"
  subnet_ids                  = ["${module.subnets.private_subnet_ids}"]
  vpc_id                      = "${module.vpc.vpc_id}"
  snapshot_identifier         = "${var.RDS_SNAPSHOT}"
  auto_minor_version_upgrade  = "false"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  skip_final_snapshot         = "false"
  copy_tags_to_snapshot       = "true"
  backup_retention_period     = 7
  backup_window               = "22:00-03:00"
}
