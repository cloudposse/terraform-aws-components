variable "service_name" {
  type        = string
  description = "Name of service owning the database (used in SSM key)"
}

variable "db_user" {
  type        = string
  description = "PostgreSQL user name to create (default is service name)"
  default     = ""
}

variable "db_password" {
  type        = string
  description = "PostgreSQL password created user (generated if not provided)"
  default     = ""
}

variable "grants" {
  type = list(object({
    grant : list(string)
    db : string
    schema : optional(string, "")
    object_type : string
  }))
  description = <<-EOT
    List of { grant: [<grant>, <grant>, ...], db: "db", schema: "", object_type: "database"}.
    EOT
  default     = [{ grant : ["ALL"], db : "*", schema : "", object_type : "database" }]
}

variable "ssm_path_prefix" {
  type        = string
  default     = "aurora-postgres"
  description = "SSM path prefix (without leading or trailing slash)"
}

variable "save_password_in_ssm" {
  type        = bool
  default     = true
  description = "If true, DB user's password will be stored in SSM"
}

variable "kms_key_id" {
  type        = string
  default     = "alias/aws/rds"
  description = "KMS key ID, ARN, or alias to use for encrypting the database"
}
