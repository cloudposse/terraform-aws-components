variable "region" {
  type        = string
  description = "AWS Region"
}

variable "grafana_component_name" {
  type        = string
  description = "The name of the Grafana component"
  default     = "managed-grafana/workspace"
}

variable "ssm_path_format_api_key" {
  type        = string
  description = "The path in AWS SSM to the Grafana API Key provisioned with this component"
  default     = "/grafana/%s/api_key"
}

variable "key_role" {
  type        = string
  description = "Specifies the permission level of the API key. Valid values are VIEWER, EDITOR, or ADMIN."
  default     = "ADMIN"
}

variable "minutes_to_live" {
  type        = number
  description = "Specifies the time in minutes until the API key expires. Keys can be valid for up to 30 days."
  default     = 43200 # 30 days
}
