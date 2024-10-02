variable "team_name" {
  type        = string
  default     = null
  description = "Current OpsGenie Team Name"
}

variable "team_naming_format" {
  type        = string
  default     = "%s_%s"
  description = "OpsGenie Team Naming Format"
}
