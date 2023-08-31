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

variable "local_datadog_monitors_config_paths" {
  type        = list(string)
  description = "List of paths to local Datadog monitor configurations"
  default     = []
}

variable "remote_datadog_monitors_config_paths" {
  type        = list(string)
  description = "List of paths to remote Datadog monitor configurations"
  default     = []
}

variable "remote_datadog_monitors_base_path" {
  type        = string
  description = "Base path to remote Datadog monitor configurations"
  default     = ""
}

variable "datadog_monitors_config_parameters" {
  type        = map(any)
  description = "Map of parameters to Datadog monitor configurations"
  default     = {}
}

variable "datadog_monitor_globals" {
  type        = any
  description = "Global parameters to add to each monitor"
  default     = {}
}

variable "datadog_monitor_context_tags_enabled" {
  type        = bool
  description = "Whether to add context tags to each monitor"
  default     = true
}

variable "datadog_monitor_context_tags" {
  type        = set(string)
  description = "List of context tags to add to each monitor"
  default     = ["namespace", "tenant", "environment", "stage"]
}

variable "message_prefix" {
  type        = string
  description = "Additional information to put before each monitor message"
  default     = ""
}

variable "message_postfix" {
  type        = string
  description = "Additional information to put after each monitor message"
  default     = ""
}
