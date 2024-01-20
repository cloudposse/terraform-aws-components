variable "region" {
  type        = string
  description = "AWS Region"
}

variable "catalog_database_name" {
  type        = string
  description = "Glue catalog database name. The acceptable characters are lowercase letters, numbers, and the underscore character"
  default     = null
}

variable "catalog_database_description" {
  type        = string
  description = "Glue catalog database description"
  default     = null
}

variable "catalog_id" {
  type        = string
  description = "ID of the Glue Catalog to create the database in. If omitted, this defaults to the AWS Account ID"
  default     = null
}

variable "create_table_default_permission" {
  #  type = object({
  #    permissions = list(string)
  #    principal = object({
  #      data_lake_principal_identifier = string
  #    })
  #  })
  type        = any
  description = "Creates a set of default permissions on the table for principals"
  default     = null
}

variable "location_uri" {
  type        = string
  description = "Location of the database (for example, an HDFS path)"
  default     = null
}

variable "parameters" {
  type        = map(string)
  description = "Map of key-value pairs that define parameters and properties of the database"
  default     = null
}

variable "target_database" {
  type = object({
    # If `target_database` is provided (not `null`), all these fields are required
    catalog_id    = string
    database_name = string
  })
  description = " Configuration block for a target database for resource linking"
  default     = null
}

variable "glue_iam_component_name" {
  type        = string
  description = "Glue IAM component name. Used to get the Glue IAM role from the remote state"
  default     = "glue/iam"
}

variable "lakeformation_permissions_enabled" {
  type        = bool
  description = "Whether to enable adding Lake Formation permissions to the IAM role that is used to access the Glue database"
  default     = true
}

variable "lakeformation_permissions" {
  type        = list(string)
  description = "List of permissions granted to the principal. Refer to https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-reference.html for more details"
  default     = ["ALL"]
}
