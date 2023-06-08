variable "service_name" {
  type        = string
  description = "Name of service owning the database (used in SSM key)"
}

variable "db_user" {
  type        = string
  description = "MySQL admin user name (default is service name)"
  default     = ""
}

variable "db_password" {
  type        = string
  description = "MySQL password for the admin user (generated if not provided)"
  default     = ""
}

variable "grants" {
  type = list(object({
    grant : list(string)
    db : string
  }))
  description = <<-EOT
    List of { grant: "[<grant>, <grant>, ...]", db: "db" }.
    Normal grants plus `ALL_APP` for all RDS allowed grants that an app should need
    (can be limited to a single database). `ALL` is not the normal MySQL `ALL` but
    is all the grants RDS allows.
    EOT
  default     = [{ grant : ["ALL_APP"], db : "*" }]
}

variable "ssm_path_prefix" {
  type        = string
  default     = "rds"
  description = "SSM path prefix"
}

variable "save_password_in_ssm" {
  type        = bool
  default     = true
  description = "If true, DB user's password will be stored in SSM"
}

variable "kms_key_id" {
  type        = string
  default     = "alias/aws/rds"
  description = "KMS key ID, ARN, or alias to use for encrypting MySQL database"
}
