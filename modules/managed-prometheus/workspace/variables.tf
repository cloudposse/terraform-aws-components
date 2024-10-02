variable "region" {
  type        = string
  description = "AWS Region"
}

variable "alert_manager_definition" {
  type        = string
  description = "The alert manager definition that you want to be applied."
  default     = ""
}

variable "rule_group_namespaces" {
  type = list(object({
    name = string
    data = string
  }))
  description = "A list of name, data objects for each Amazon Managed Service for Prometheus (AMP) Rule Group Namespace"
  default     = []
}

variable "grafana_account_name" {
  type        = string
  description = "The name of the account allowed to access AMP in this account. If defined, this module will create a cross-account IAM role for accessing AMP. Use this for cross-account Grafana. If not defined, no roles will be created."
  default     = ""
}

variable "account_map_tenant_name" {
  type        = string
  description = "The name of the tenant where `account_map` is provisioned"
  default     = "core"
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "vpc_endpoint_enabled" {
  type        = string
  description = "If set to `true`, restrict traffic through a VPC endpoint"
  default     = true
}
