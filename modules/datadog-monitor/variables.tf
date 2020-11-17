variable "region" {
  type        = string
  description = "AWS Region"
}

variable "alert_tags" {
  type        = list(string)
  description = "List of alert tags to add to all alert messages, e.g. `[\"@opsgenie\"]` or `[\"@devops\", \"@opsgenie\"]`"
  default     = null
}

variable "alert_tags_separator" {
  type        = string
  description = "Separator for the alert tags. All strings from the `alert_tags` variable will be joined into one string using the separator and then added to the alert message"
  default     = "\n"
}

variable "ssm_parameter_name_format" {
  type        = string
  default     = "/%s/%s"
  description = "SSM parameter name format"
}

variable "ssm_path" {
  type        = string
  default     = "datadog"
  description = "SSM path"
}

variable "datadog_monitors_config_paths" {
  type        = list(string)
  description = "List of paths to Datadog monitor configurations"
}
