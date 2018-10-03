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

variable "RDS_ENGINE" {
  type        = "string"
  default     = "mysql"
  description = "RDS DB engine"
}

variable "RDS_ENGINE_VERSION" {
  type        = "string"
  default     = "5.6"
  description = "RDS DB engine version"
}

variable "RDS_DB_PARAMETER_GROUP" {
  type        = "string"
  default     = "mysql5.6"
  description = "RDS DB engine version"
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

variable "RDS_MULTI_AZ" {
  type        = "string"
  default     = "false"
  description = "Run instaces in multiple az"
}

variable "RDS_STORAGE_TYPE" {
  type        = "string"
  default     = "gp2"
  description = "Storage type"
}

variable "RDS_STORAGE_SIZE" {
  type        = "string"
  default     = "20"
  description = "Storage size"
}

variable "RDS_STORAGE_ENCRYPTED" {
  type        = "string"
  default     = "false"
  description = "Set true to encrypt storage"
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
  multi_az                    = "${var.RDS_MULTI_AZ}"
  storage_type                = "${var.RDS_STORAGE_TYPE}"
  allocated_storage           = "${var.RDS_STORAGE_SIZE}"
  storage_encrypted           = "${var.RDS_STORAGE_ENCRYPTED}"
  engine                      = "${var.RDS_ENGINE}"
  engine_version              = "${var.RDS_ENGINE_VERSION}"
  instance_class              = "${var.RDS_INSTANCE_TYPE}"
  db_parameter_group          = "${var.RDS_DB_PARAMETER_GROUP}"
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

output "rds_instance_id" {
  value       = "${module.rds.instance_id}"
  description = "RDS ID of the instance"
}

output "rds_instance_address" {
  value       = "${module.rds.instance_address}"
  description = "RDS address of the instance"
}

output "rds_instance_endpoint" {
  value       = "${module.rds.instance_endpoint}"
  description = "RDS DNS Endpoint of the instance"
}

output "rds_db_name" {
  value       = "${var.RDS_DB_NAME}"
  description = "RDS db name"
}

output "rds_root_user" {
  value       = "${var.RDS_ADMIN_NAME}"
  description = "RDS root name"
}

output "rds_root_password" {
  value       = "${var.RDS_ADMIN_PASSWORD}"
  description = "RDS root password"
}

output "rds_hostname" {
  value       = "${module.rds.hostname}"
  description = "RDS host name of the instance"
}
