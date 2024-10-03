variable "region" {
  type        = string
  description = "AWS Region"
}

variable "aurora_postgres_component_name" {
  type        = string
  description = "Aurora Postgres component name to read the remote state from"
  default     = "aurora-postgres"
}

variable "read_passwords_from_ssm" {
  type        = bool
  default     = true
  description = "When `true`, fetch user passwords from SSM"
}

variable "ssm_path_prefix" {
  type        = string
  default     = "aurora-postgres"
  description = "SSM path prefix"
}

variable "ssm_password_source" {
  type        = string
  default     = ""
  description = <<-EOT
    If var.read_passwords_from_ssm is true, DB user passwords will be retrieved from SSM using `var.ssm_password_source` and the database username. If this value is not set, a default path will be created using the SSM path prefix and ID of the associated Aurora Cluster.
    EOT
}

variable "admin_password" {
  type        = string
  description = "postgresql password for the admin user"
  default     = ""
}

variable "db_name" {
  type        = string
  description = "Database name (default is not to create a database)"
  default     = ""
}

variable "cluster_enabled" {
  type        = string
  default     = true
  description = "Set to `false` to prevent the module from creating any resources"
}

variable "additional_databases" {
  type        = set(string)
  default     = []
  description = "Additional databases to be created with the cluster"
}

variable "additional_users" {
  # map key is service name, becomes part of SSM key name
  type = map(object({
    db_user : string
    db_password : string
    grants : list(object({
      grant : list(string)
      db : string
      schema : string
      object_type : string
    }))
  }))
  default     = {}
  description = <<-EOT
    Create additional database user for a service, specifying username, grants, and optional password.
    If no password is specified, one will be generated. Username and password will be stored in
    SSM parameter store under the service's key.
    EOT
}

variable "additional_grants" {
  # map key is user name
  type = map(list(object({
    grant : list(string)
    db : string
  })))
  default     = {}
  description = <<-EOT
    Create additional database user with specified grants.
    If `var.ssm_password_source` is set, passwords will be retrieved from SSM parameter store,
    otherwise, passwords will be generated and stored in SSM parameter store under the service's key.
    EOT
}

variable "additional_schemas" {
  # Map key is the name of the schema
  type = map(object({
    database : string
  }))
  default     = {}
  description = <<-EOT
    Create additional schemas for a given database.
    If no database is given, the schema will use the database used by the provider configuration
  EOT
}
