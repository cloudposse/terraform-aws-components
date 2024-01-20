variable "region" {
  type        = string
  description = "AWS Region"
}

variable "trigger_name" {
  type        = string
  description = "Glue trigger name. If not provided, the name will be generated from the context"
  default     = null
}

variable "trigger_description" {
  type        = string
  description = "Glue trigger description"
  default     = null
}

variable "type" {
  type        = string
  description = "The type of trigger. Options are CONDITIONAL, SCHEDULED or ON_DEMAND"
  default     = "CONDITIONAL"

  validation {
    condition     = contains(["CONDITIONAL", "SCHEDULED", "ON_DEMAND"], var.type)
    error_message = "Supported options are CONDITIONAL, SCHEDULED or ON_DEMAND"
  }
}

variable "predicate" {
  #  type = object({
  #    # How to handle multiple conditions. Defaults to `AND`. Valid values are `AND` or `ANY`
  #    logical = string
  #    # Conditions for activating the trigger. Required for triggers where type is `CONDITIONAL`
  #    conditions = list(object({
  #      job_name         = string
  #      crawler_name     = string
  #      state            = string
  #      crawl_state      = string
  #      logical_operator = string
  #    }))
  #  })
  type        = any
  description = "A predicate to specify when the new trigger should fire. Required when trigger type is `CONDITIONAL`"
  default     = null
}

variable "event_batching_condition" {
  #  type = object({
  #    batch_size   = number
  #    batch_window = number
  #  })
  type        = map(number)
  description = "Batch condition that must be met (specified number of events received or batch time window expired) before EventBridge event trigger fires"
  default     = null
}

variable "schedule" {
  type        = string
  description = "Cron formatted schedule. Required for triggers with type `SCHEDULED`"
  default     = null
}

variable "trigger_enabled" {
  type        = bool
  description = "Whether to start the created trigger"
  default     = true
}

variable "start_on_creation" {
  type        = bool
  description = "Set to `true` to start `SCHEDULED` and `CONDITIONAL` triggers when created. `true` is not supported for `ON_DEMAND` triggers"
  default     = true
}

variable "glue_workflow_component_name" {
  type        = string
  description = "Glue workflow component name. Used to get the Glue workflow from the remote state"
  default     = null
}

variable "glue_job_component_name" {
  type        = string
  description = "Glue workflow job name. Used to get the Glue job from the remote state"
  default     = null
}

variable "glue_job_timeout" {
  type        = number
  description = "The job run timeout in minutes. It overrides the timeout value of the job"
  default     = null
}

variable "actions" {
  #  type = list(object({
  #    job_name               = string
  #    crawler_name           = string
  #    arguments              = map(string)
  #    security_configuration = string
  #    notification_property = object({
  #      notify_delay_after = number
  #    })
  #    timeout = number
  #  }))
  type        = list(any)
  description = "List of actions initiated by the trigger when it fires"
  default     = null
}
