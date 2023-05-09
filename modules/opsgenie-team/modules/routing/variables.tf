variable "criteria" {
  type = object({
    type       = string,
    conditions = any
  })
  description = "Criteria of the Routing Rule, rules to match or not"
}

variable "type" {
  type    = string
  default = "alert"
  validation {
    condition     = contains(["alert", "incident"], var.type)
    error_message = "Allowed values: `alert`, `incident`."
  }
  description = "Type of Routing Rule Alert or Incident"
}

variable "services" {
  type        = map(any)
  default     = null
  description = "Team services to associate with incident routing rules"
}

variable "notify" {
  type = map(any)
  validation {
    condition     = contains(["schedule", "escalation", "none"], var.notify.type)
    error_message = "Allowed values: `schedule`, `escalation`, `none`."
  }
  description = "Notification of team alerting rule"
}

variable "order" {
  type        = number
  description = "Order of the alerting rule"
}

variable "priority" {
  type        = string
  description = "Priority level of custom Incidents"
}

variable "incident_properties" {
  #  type = object({
  #    message             = string
  #    description         = string
  #    services            = list(string)
  #    update_stakeholders = bool
  #  })
  type        = map(any)
  description = "Properties to override on the incident routing rule"
}

variable "timezone" {
  type        = string
  default     = null
  description = "Timezone for this alerting route"
}

variable "time_restriction" {
  type        = any
  default     = null
  description = "Time restriction of alert routing rule"
}

variable "is_default" {
  type        = bool
  default     = false
  description = "Set this alerting route as the default route"

}
