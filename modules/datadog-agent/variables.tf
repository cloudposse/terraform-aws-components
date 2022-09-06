variable "region" {
  type        = string
  description = "AWS Region"
}

variable "secrets_store_type" {
  type        = string
  description = "Secret store type for Datadog API and app keys. Valid values: `SSM`, `ASM`"
  default     = "SSM"
}

variable "datadog_api_secret_key" {
  type        = string
  description = "The key of the Datadog API secret"
  default     = "datadog/datadog_api_key"
}

variable "datadog_app_secret_key" {
  type        = string
  description = "The key of the Datadog Application secret"
  default     = "datadog/datadog_app_key"
}

variable "datadog_tags" {
  type        = set(string)
  description = "List of static tags to attach to every metric, event and service check collected by the agent"
  default     = []
}

variable "cluster_checks_enabled" {
  type        = bool
  description = "Enable Cluster Checks for the Datadog Agent"
  default     = false
}

variable "datadog_cluster_check_config_parameters" {
  type        = map(any)
  description = "Map of parameters to Datadog Cluster Check configurations"
  default     = {}
}

variable "datadog_cluster_check_config_paths" {
  type        = list(string)
  description = "List of paths to Datadog Cluster Check configurations"
  default     = []
}

variable "datadog_cluster_check_auto_added_tags" {
  type        = list(string)
  description = "List of tags to add to Datadog Cluster Check"
  default     = ["stage", "environment"]
}
