variable "region" {
  type        = string
  description = "AWS region"
}

variable "enable_update_github_app_webhook" {
  type        = bool
  description = "Enable updating the github app webhook"
  default     = false
}

variable "lambda_repo_url" {
  type        = string
  description = "URL of the lambda repository"
  default     = "https://github.com/philips-labs/terraform-aws-github-runner"
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

variable "instance_types" {
  description = "List of instance types for the action runner. Defaults are based on runner_os (al2023 for linux and Windows Server Core for win)."
  type        = list(string)
  default     = ["m5.large", "c5.large"]
}

variable "repository_white_list" {
  description = "List of github repository full names (owner/repo_name) that will be allowed to use the github app. Leave empty for no filtering."
  type        = list(string)
  default     = []
}
