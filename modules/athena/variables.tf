variable "region" {
  type        = string
  description = "AWS Region"
}

variable "create_s3_bucket" {
  description = "Enable the creation of an S3 bucket to use for Athena query results"
  type        = bool
  default     = true
}

variable "athena_s3_bucket_id" {
  description = "Use an existing S3 bucket for Athena query results if `create_s3_bucket` is `false`."
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Enable the creation of a KMS key used by Athena workgroup."
  type        = bool
  default     = true
}

variable "athena_kms_key" {
  description = "Use an existing KMS key for Athena if `create_kms_key` is `false`."
  type        = string
  default     = null
}

variable "athena_kms_key_deletion_window" {
  description = "KMS key deletion window (in days)."
  type        = number
  default     = 7
}

variable "workgroup_description" {
  description = "Description of the Athena workgroup."
  type        = string
  default     = ""
}

variable "bytes_scanned_cutoff_per_query" {
  description = "Integer for the upper data usage limit (cutoff) for the amount of bytes a single query in a workgroup is allowed to scan. Must be at least 10485760."
  type        = number
  default     = null
}

variable "enforce_workgroup_configuration" {
  description = "Boolean whether the settings for the workgroup override client-side settings."
  type        = bool
  default     = true
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Boolean whether Amazon CloudWatch metrics are enabled for the workgroup."
  type        = bool
  default     = true
}

variable "workgroup_encryption_option" {
  description = "Indicates whether Amazon S3 server-side encryption with Amazon S3-managed keys (SSE_S3), server-side encryption with KMS-managed keys (SSE_KMS), or client-side encryption with KMS-managed keys (CSE_KMS) is used."
  type        = string
  default     = "SSE_KMS"
}

variable "s3_output_path" {
  description = "The S3 bucket path used to store query results."
  type        = string
  default     = ""
}

variable "workgroup_state" {
  description = "State of the workgroup. Valid values are `DISABLED` or `ENABLED`."
  type        = string
  default     = "ENABLED"
}

variable "workgroup_force_destroy" {
  description = "The option to delete the workgroup and its contents even if the workgroup contains any named queries."
  type        = bool
  default     = false
}

variable "databases" {
  description = "Map of Athena databases and related configuration."
  type        = map(any)
}

variable "data_catalogs" {
  description = "Map of Athena data catalogs and parameters"
  type        = map(any)
  default     = {}
}

variable "named_queries" {
  description = "Map of Athena named queries and parameters"
  type        = map(map(string))
  default     = {}
}

variable "cloudtrail_database" {
  description = "The name of the Athena Database to use for CloudTrail logs. If set, an Athena table will be created for the CloudTrail trail."
  type        = string
  default     = ""
}

variable "cloudtrail_bucket_component_name" {
  type        = string
  description = "The name of the CloudTrail bucket component"
  default     = "cloudtrail-bucket"
}
