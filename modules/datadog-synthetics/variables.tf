variable "region" {
  type        = string
  description = "AWS Region"
}

variable "synthetics_paths" {
  type        = list(string)
  description = "List of paths to Datadog synthetic test configurations"
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

variable "context_tags_enabled" {
  type        = bool
  description = "Whether to add context tags to add to each synthetic check"
  default     = true
}

variable "context_tags" {
  type        = set(string)
  description = "List of context tags to add to each synthetic check"
  default     = ["namespace", "tenant", "environment", "stage"]
}

variable "config_parameters" {
  type        = map(any)
  description = "Map of parameters to Datadog Synthetic configurations"
  default     = {}
}

variable "datadog_synthetics_globals" {
  type        = any
  description = "Map of keys to add to every monitor"
  default     = {}
}

variable "locations" {
  type        = list(string)
  description = "Array of locations used to run synthetic tests"
  default     = ["all"]
}

variable "private_location_test_enabled" {
  type        = bool
  description = "Use private locations or the public locations provided by datadog"
  default     = false
}

variable "synthetics_private_location_component_name" {
  type        = string
  description = "The name of the Datadog synthetics private location component"
  default     = null
}
