variable "region" {
  type        = string
  description = "AWS Region"
}

variable "aurora_postgres_component_name" {
  type        = string
  description = "Aurora Postgres component name to read the remote state from"
}

variable "additional_databases" {
  type        = set(string)
  default     = []
  description = "Define additional databases to create."
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
  description = "Define additional users to create."
}
