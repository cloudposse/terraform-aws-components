variable "region" {
  type        = string
  description = "AWS Region"
}

variable "crawler_name" {
  type        = string
  description = "Glue crawler name. If not provided, the name will be generated from the context"
  default     = null
}

variable "crawler_description" {
  type        = string
  description = "Glue crawler description"
  default     = null
}

variable "schedule" {
  type        = string
  description = "A cron expression for the schedule"
  default     = null
}

variable "classifiers" {
  type        = list(string)
  description = "List of custom classifiers. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification"
  default     = null
}

variable "configuration" {
  type        = string
  description = "JSON string of configuration information"
  default     = null
}

variable "jdbc_target" {
  #  type = list(object({
  #    connection_name = string
  #    path            = string
  #    exclusions      = list(string)
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = list(any)
  description = "List of nested JDBC target arguments"
  default     = null
}

variable "dynamodb_target" {
  #  type = list(object({
  #    path      = string
  #    scan_all  = bool
  #    scan_rate = number
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = list(any)
  description = "List of nested DynamoDB target arguments"
  default     = null
}

variable "s3_target" {
  #  type = list(object({
  #    path                = string
  #    connection_name     = string
  #    exclusions          = list(string)
  #    sample_size         = number
  #    event_queue_arn     = string
  #    dlq_event_queue_arn = string
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = list(any)
  description = "List of nested Amazon S3 target arguments"
  default     = null
}

variable "mongodb_target" {
  #  type = list(object({
  #    connection_name = string
  #    path            = string
  #    scan_all        = bool
  #  }))

  # Using `type = list(any)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = list(any)
  description = "List of nested MongoDB target arguments"
  default     = null
}

variable "catalog_target" {
  type = list(object({
    database_name = string
    tables        = list(string)
  }))
  description = "List of nested Glue catalog target arguments"
  default     = null
}

variable "delta_target" {
  type = list(object({
    connection_name = string
    delta_tables    = list(string)
    write_manifest  = bool
  }))
  description = "List of nested Delta target arguments"
  default     = null
}

variable "table_prefix" {
  type        = string
  description = "The table prefix used for catalog tables that are created"
  default     = null
}

variable "security_configuration" {
  type        = string
  description = "The name of Security Configuration to be used by the crawler"
  default     = null
}

variable "schema_change_policy" {
  #  type = object({
  #    delete_behavior = string
  #    update_behavior = string
  #  })

  # Using `type = map(string)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = map(string)
  description = "Policy for the crawler's update and deletion behavior"
  default     = null
}

variable "lineage_configuration" {
  type = object({
    crawler_lineage_settings = string
  })
  description = "Specifies data lineage configuration settings for the crawler"
  default     = null
}

variable "recrawl_policy" {
  type = object({
    recrawl_behavior = string
  })
  description = "A policy that specifies whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run"
  default     = null
}

variable "glue_iam_component_name" {
  type        = string
  description = "Glue IAM component name. Used to get the Glue IAM role from the remote state"
  default     = "glue/iam"
}

variable "glue_catalog_database_component_name" {
  type        = string
  description = "Glue catalog database component name where metadata resides. Used to get the Glue catalog database from the remote state"
}

variable "glue_catalog_table_component_name" {
  type        = string
  description = "Glue catalog table component name where metadata resides. Used to get the Glue catalog table from the remote state"
  default     = null
}
