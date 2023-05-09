variable "region" {
  type        = string
  description = "AWS Region"
}

variable "datadog_tags" {
  type        = set(string)
  description = "List of static tags to attach to every metric, event and service check collected by the agent"
  default     = []
}

variable "cluster_checks_enabled" {
  type        = bool
  description = "Enable Cluster Checks for the Datadog Agent"
  default     = false
}

variable "datadog_cluster_check_config_parameters" {
  type        = map(any)
  description = "Map of parameters to Datadog Cluster Check configurations"
  default     = {}
}

variable "datadog_cluster_check_config_paths" {
  type        = list(string)
  description = "List of paths to Datadog Cluster Check configurations"
  default     = []
}

variable "datadog_cluster_check_auto_added_tags" {
  type        = list(string)
  description = "List of tags to add to Datadog Cluster Check"
  default     = ["stage", "environment"]
}

variable "eks_component_name" {
  type        = string
  description = "The name of the EKS component. Used to get the remote state"
  default     = "eks/eks"
}

variable "values" {
  type        = any
  description = "Additional values to yamlencode as `helm_release` values."
  default     = {}
}

variable "iam_role_enabled" {
  type        = bool
  description = "Whether to create an IAM role. Setting this to `true` will also replace any occurrences of `{service_account_role_arn}` in `var.values_template_path` with the ARN of the IAM role created by this module."
  default     = false
}

variable "iam_policy_statements" {
  type        = any
  description = "IAM policy for the service account. Required if `var.iam_role_enabled` is `true`. This will not do variable replacements. Please see `var.iam_policy_statements_template_path`."
  default     = {}
}
