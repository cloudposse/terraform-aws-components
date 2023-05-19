variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_tenant" {
  type        = string
  default     = ""
  description = "The tenant where the `account_map` component required by remote-state is deployed"
}

variable "root_account_stage" {
  type        = string
  default     = "root"
  description = "The stage name for the Organization root (master) account"
}

variable "global_environment" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "central_resource_collector_account" {
  description = "The name of the account that is the centralized aggregation account"
  type        = string
}

variable "central_logging_account" {
  description = <<-DOC
    The name of the account that is the centralized logging account. The config rules associated with logging in the 
    catalog (loggingAccountOnly: true) will be installed only in this account.
  DOC
  type        = string
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
}

variable "create_sns_topic" {
  description = "Flag to indicate whether an SNS topic should be created for notifications"
  type        = bool
  default     = false
}

variable "enabled_standards" {
  description = "A list of standards to enable in the account"
  type        = set(string)
  default     = []
}

variable "admin_delegated" {
  type        = bool
  default     = true
  description = <<DOC
  A flag to indicate if the Security Hub Admininstrator account has been designated from the root account.

  This component should be applied with this variable set to false, then the securityhub-root component should be applied
  to designate the administrator account, then this component should be applied again with this variable set to `true`.
  DOC
}

variable "opsgenie_sns_topic_subscription_enabled" {
  description = "Flag to indicate whether OpsGenie should be subscribed to SecurityHub notifications"
  type        = bool
  default     = false
}

variable "opsgenie_integration_uri_key_pattern" {
  type        = string
  description = <<-DOC
  The format string (%v will be replaced by the var.opsgenie_webhook_uri_key) for the
  key of the SSM Parameter containing the OpsGenie AmazonSecurityHub API Integration Webhook URI.
  Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`.
  DOC
  default     = "/opsgenie/%v"
}

variable "opsgenie_integration_uri_key" {
  type        = string
  description = <<-DOC
  The key of the SSM Parameter containing the OpsGenie AmazonSecurityHub API Integration Webhook URI.
  Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`.
  DOC
  default     = "opsgenie_securityhub_uri"
}

variable "opsgenie_integration_uri_ssm_account" {
  type        = string
  description = <<-DOC
  Account (stage) holding the SSM Parameter for the OpsGenie AmazonSecurityHub API Integration URI.
  Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`.
  DOC
}

variable "opsgenie_integration_uri_ssm_region" {
  type        = string
  description = <<-DOC
  SSM Parameter Store AWS region for the OpsGenie AmazonSecurityHub API Integration URI.
  Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`.
  DOC
}