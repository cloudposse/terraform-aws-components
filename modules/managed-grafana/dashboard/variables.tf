variable "region" {
  type        = string
  description = "AWS Region"
}

variable "dashboard_name" {
  type        = string
  description = "The name to use for the dashboard. This must be unique."
}

variable "dashboard_url" {
  type        = string
  description = "The marketplace URL of the dashboard to be created"
}

variable "additional_config" {
  type        = map(any)
  description = "Additional dashboard configuration to be merged with the provided dashboard JSON"
  default     = {}
}

variable "config_input" {
  type        = map(string)
  description = "A map of string replacements used to supply input for the dashboard config JSON"
  default     = {}
}
