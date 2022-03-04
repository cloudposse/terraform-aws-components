variable "region" {
  type        = string
  description = "AWS Region"
}

variable "description" {
  type        = string
  default     = null
  description = "Team Description in Opsgenie"
}

variable "schedules" {
  type        = map(any)
  default     = {}
  description = "Schedules to create for the team"
}

variable "services" {
  type        = map(any)
  default     = {}
  description = "Services to create and register to the team."
}

variable "members" {
  type        = set(any)
  default     = []
  description = "Members as objects with their role within the team."
}

variable "integrations" {
  type        = map(any)
  default     = {}
  description = "API Integrations for the team. If not specified, `datadog` is assumed."
}

variable "routing_rules" {
  type        = any
  default     = null
  description = "Routing Rules for the team"
}

# TODO: evaluation if all integrations or only Datadog integration should be recreated per tenant per team
variable "create_only_integrations_enabled" {
  type        = bool
  default     = false
  description = "Whether to reuse all existing resources and only create new integrations"
}

variable "ignore_team_members" {
  type = bool
  default = false
  description = "Set to true to ignore any configured member blocks and any team member added/updated/removed via OpsGenie web UI."
}

variable "escalations" {
  type        = map(any)
  default     = {}
  description = "Escalations to configure and create for the team. "
}
