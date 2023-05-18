variable "region" {
  type        = string
  description = "AWS Region"
}

variable "datadog_site_url" {
  type        = string
  description = "The Datadog Site URL, https://docs.datadoghq.com/getting_started/site/"
  default     = null

  validation {
    condition = var.datadog_site_url == null ? true : contains([
      "datadoghq.com",
      "us3.datadoghq.com",
      "us5.datadoghq.com",
      "datadoghq.eu",
      "ddog-gov.com"
    ], var.datadog_site_url)
    error_message = "Allowed values: null, `datadoghq.com`, `us3.datadoghq.com`, `us5.datadoghq.com`, `datadoghq.eu`, `ddog-gov.com`."
  }
}

variable "datadog_secrets_store_type" {
  type        = string
  description = "Secret Store type for Datadog API and app keys. Valid values: `SSM`, `ASM`"
  default     = "SSM"
}

variable "datadog_secrets_source_store_account_region" {
  type        = string
  description = "Region for holding Secret Store Datadog Keys, leave as null to use the same region as the stack"
  default     = null
}

variable "datadog_secrets_source_store_account_stage" {
  type        = string
  description = "Stage holding Secret Store for Datadog API and app keys."
  default     = "auto"
}

variable "datadog_secrets_source_store_account_tenant" {
  type        = string
  description = "Tenant holding Secret Store for Datadog API and app keys."
  default     = "core"
}

variable "datadog_api_secret_key_source_pattern" {
  type        = string
  description = "The format string (%v will be replaced by the var.datadog_api_secret_key) for the key of the Datadog API secret in the source account"
  default     = "/datadog/%v/datadog_api_key"
}

variable "datadog_app_secret_key_source_pattern" {
  type        = string
  description = "The format string (%v will be replaced by the var.datadog_app_secret_key) for the key of the Datadog APP secret in the source account"
  default     = "/datadog/%v/datadog_app_key"
}

variable "datadog_api_secret_key_target_pattern" {
  type        = string
  description = "The format string (%v will be replaced by the var.datadog_api_secret_key) for the key of the Datadog API secret in the target account"
  default     = "/datadog/datadog_api_key"
}

variable "datadog_app_secret_key_target_pattern" {
  type        = string
  description = "The format string (%v will be replaced by the var.datadog_api_secret_key) for the key of the Datadog APP secret in the target account"
  default     = "/datadog/datadog_app_key"
}

variable "datadog_api_secret_key" {
  type        = string
  description = "The name of the Datadog API secret"
  default     = "default"
}

variable "datadog_app_secret_key" {
  type        = string
  description = "The name of the Datadog APP secret"
  default     = "default"
}
