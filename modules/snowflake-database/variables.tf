variable "region" {
  type        = string
  description = "AWS Region"
}

variable "data_retention_time_in_days" {
  type        = string
  description = "Time in days to retain data in Snowflake databases, schemas, and tables by default."
  default     = 1
}

variable "tables" {
  type        = map(any)
  description = "A map of tables to create for Snowflake. A schema and database will be assigned for this group of tables."
  default     = {}
}

variable "views" {
  type        = map(any)
  description = "A map of views to create for Snowflake. The same schema and database will be assigned as for tables."
  default     = {}
}

variable "database_grants" {
  type        = list(string)
  description = "A list of Grants to give to the database created with component."
  default     = ["MODIFY", "MONITOR", "USAGE"]
}

variable "schema_grants" {
  type        = list(string)
  description = "A list of Grants to give to the schema created with component."
  default     = ["MODIFY", "MONITOR", "USAGE", "CREATE TABLE", "CREATE VIEW"]
}

variable "table_grants" {
  type        = list(string)
  description = "A list of Grants to give to the tables created with component."
  default     = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES"]
}

variable "view_grants" {
  type        = list(string)
  description = "A list of Grants to give to the views created with component."
  default     = ["SELECT", "REFERENCES"]
}

variable "database_comment" {
  type        = string
  description = "The comment to give to the provisioned database."
  default     = "A database created for managing programmatically created Snowflake schemas and tables."
}
