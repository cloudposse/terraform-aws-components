variable "region" {
  type        = string
  description = "AWS region"
}

variable "enable_update_github_app_webhook" {
  type        = bool
  description = "Enable updating the github app webhook"
  default     = false
}

variable "release_version" {
  type        = string
  description = "Version of the application"
  default     = "v5.4.0"
}

variable "github_app_key_ssm_path" {
  type        = string
  description = "Path to the github key in SSM"
  default     = "/pl-github-runners/key"
}

variable "github_app_id_ssm_path" {
  type        = string
  description = "Path to the github app id in SSM"
  default     = "/pl-github-runners/id"
}

variable "runner_extra_labels" {
  description = "Extra (custom) labels for the runners (GitHub). Labels checks on the webhook can be enforced by setting `enable_workflow_job_labels_check`. GitHub read-only labels should not be provided."
  type        = list(string)
  default     = ["default"]
}

variable "scale_up_reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
  type        = number
  # default from philips labs is 1, which gives an error when creating the lambda Specified ReservedConcurrentExecutions for function decreases account's UnreservedConcurrentExecution below its minimum value of [10]
  # https://github.com/philips-labs/terraform-aws-github-runner/issues/1671
  default = -1
}

variable "instance_target_capacity_type" {
  description = "Default lifecycle used for runner instances, can be either `spot` or `on-demand`."
  type        = string
  default     = "spot"
  validation {
    condition     = contains(["spot", "on-demand"], var.instance_target_capacity_type)
    error_message = "The instance target capacity should be either spot or on-demand."
  }
}

variable "create_service_linked_role_spot" {
  description = "(optional) create the service linked role for spot instances that is required by the scale-up lambda."
  type        = bool
  default     = true
}

variable "ssm_paths" {
  description = "The root path used in SSM to store configuration and secrets."
  type = object({
    root       = optional(string, "github-action-runners")
    app        = optional(string, "app")
    runners    = optional(string, "runners")
    use_prefix = optional(bool, true)
  })
  default = {}
}
