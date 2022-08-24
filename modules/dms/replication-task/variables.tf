variable "region" {
  type        = string
  description = "AWS Region"
}

variable "start_replication_task" {
  type        = bool
  description = "If set to `true`, the created replication tasks will be started automatically"
  default     = true
}

variable "migration_type" {
  type        = string
  description = "The migration type. Can be one of `full-load`, `cdc`, `full-load-and-cdc`"
  default     = "full-load-and-cdc"
}

variable "cdc_start_position" {
  type        = string
  description = "Indicates when you want a change data capture (CDC) operation to start. The value can be in date, checkpoint, or LSN/SCN format depending on the source engine, Conflicts with `cdc_start_time`"
  default     = null
}

variable "cdc_start_time" {
  type        = string
  description = "The Unix timestamp integer for the start of the Change Data Capture (CDC) operation. Conflicts with `cdc_start_position`"
  default     = null
}

variable "replication_task_settings_file" {
  type        = string
  description = "Path to the JSON file that contains the task settings. See https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.html for more details"
  default     = null
}

variable "table_mappings_file" {
  type        = string
  description = "Path to the JSON file that contains the table mappings. See https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TableMapping.html for more details"
}

variable "replication_instance_component_name" {
  type        = string
  description = "DMS replication instance component name (used to get the ARN of the DMS replication instance)"
}

variable "source_endpoint_component_name" {
  type        = string
  description = "DMS source endpoint component name (used to get the ARN of the DMS source endpoint)"
}

variable "target_endpoint_component_name" {
  type        = string
  description = "DMS target endpoint component name (used to get the ARN of the DMS target endpoint)"
}
