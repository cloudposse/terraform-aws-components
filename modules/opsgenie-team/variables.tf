variable "region" {
  type        = string
  description = "AWS Region"
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

variable "integrations_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable the integrations submodule or not"
}

variable "team_options" {
  type = object({
    description              = optional(string)
    ignore_members           = optional(bool, false)
    delete_default_resources = optional(bool, false)
  })
  description = <<-EOT
    Configure the team options.
    See `opsgenie_team` Terraform resource [documentation](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs/resources/team#argument-reference) for more details.
    EOT
  default     = {}
  nullable    = false
}

variable "escalations" {
  type        = map(any)
  default     = {}
  description = "Escalations to configure and create for the team. "
}
