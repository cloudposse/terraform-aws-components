variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ssm_path_prefix" {
  type        = string
  default     = "rds"
  description = "SSM path prefix"
}

variable "ssm_password_source" {
  type        = string
  default     = ""
  description = "If set, DB Admin user password will be retrieved from SSM using the key `format(var.ssm_password_source, local.db_username)`"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the RDS cluster"
}

variable "mysql_name" {
  type        = string
  description = "MySQL solution name (part of cluster identifier)"
  default     = ""
}

variable "mysql_db_name" {
  type        = string
  description = "Database name (default is not to create a database"
  default     = ""
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

# https://aws.amazon.com/rds/RDS/pricing
variable "mysql_instance_type" {
  type        = string
  default     = "db.t3.medium"
  description = "EC2 instance type for RDS MySQL cluster"
}

variable "aurora_mysql_engine" {
  type        = string
  description = "Engine for Aurora database: `aurora` for MySQL 5.6, `aurora-mysql` for MySQL 5.7"
}

variable "aurora_mysql_engine_version" {
  type        = string
  description = "Engine Version for Aurora database."
  default     = ""
}

variable "aurora_mysql_cluster_family" {
  type        = string
  description = "DBParameterGroupFamily (e.g. `aurora5.6`, `aurora-mysql5.7` for Aurora MySQL databases). See https://stackoverflow.com/a/55819394 for help finding the right one to use."
}

variable "aurora_mysql_cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB cluster parameters to apply"
}

variable "aurora_mysql_instance_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB instance parameters to apply"
}

variable "mysql_cluster_size" {
  type        = string
  default     = 2
  description = "MySQL cluster size"
}

variable "mysql_cluster_enabled" {
  type        = string
  default     = true
  description = "Set to `false` to prevent the module from creating any resources"
}

variable "mysql_storage_encrypted" {
  type        = string
  default     = true
  description = "Set to `true` to keep the database contents encrypted"
}

variable "mysql_deletion_protection" {
  type        = string
  default     = true
  description = "Set to `true` to protect the database from deletion"
}

variable "mysql_skip_final_snapshot" {
  type        = string
  default     = false
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
}

variable "mysql_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery"
  default     = ["audit", "error", "general", "slowquery"]
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Set `true` to enable Performance Insights"
  default     = false
}

variable "mysql_backup_retention_period" {
  type        = number
  default     = 3
  description = "Number of days for which to retain backups"
}

variable "mysql_backup_window" {
  type        = string
  default     = "07:00-09:00"
  description = "Daily time range during which the backups happen"
}

variable "mysql_maintenance_window" {
  type        = string
  default     = "sat:10:00-sat:10:30"
  description = "Weekly time range during which system maintenance can occur, in UTC"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = false
  description = "Automatically update the cluster when a new minor version is released"
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "eks_component_name" {
  type        = string
  description = "The name of the eks component"
  default     = "eks/eks"
}
