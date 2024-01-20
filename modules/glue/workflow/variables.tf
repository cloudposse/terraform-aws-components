variable "region" {
  type        = string
  description = "AWS Region"
}

variable "workflow_name" {
  type        = string
  description = "Glue workflow name. If not provided, the name will be generated from the context"
  default     = null
}

variable "workflow_description" {
  type        = string
  description = "Glue workflow description"
  default     = null
}

variable "default_run_properties" {
  type        = map(string)
  description = "A map of default run properties for this workflow. These properties are passed to all jobs associated to the workflow"
  default     = null
}

variable "max_concurrent_runs" {
  type        = number
  description = "Maximum number of concurrent runs. If you leave this parameter blank, there is no limit to the number of concurrent workflow runs"
  default     = null
}
