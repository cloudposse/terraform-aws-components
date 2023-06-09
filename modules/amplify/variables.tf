variable "region" {
  type        = string
  description = "AWS region"
}

variable "github_personal_access_token_secret_path" {
  description = "Path to the GitHub personal access token in AWS Parameter Store"
  default     = "/amplify/github_personal_access_token"
  type        = string
}

variable "description" {
  type        = string
  description = "The description for the Amplify app"
  default     = null
}

variable "repository" {
  type        = string
  description = "The repository for the Amplify app"
  default     = null
}

variable "platform" {
  type        = string
  description = "The platform or framework for the Amplify app"
  default     = "WEB"
}

variable "oauth_token" {
  type        = string
  description = <<-EOT
    The OAuth token for a third-party source control system for the Amplify app.
    The OAuth token is used to create a webhook and a read-only deploy key.
    The OAuth token is not stored.
    EOT
  default     = null
  sensitive   = true
}

variable "auto_branch_creation_config" {
  type = object({
    basic_auth_credentials        = optional(string)
    build_spec                    = optional(string)
    enable_auto_build             = optional(bool)
    enable_basic_auth             = optional(bool)
    enable_performance_mode       = optional(bool)
    enable_pull_request_preview   = optional(bool)
    environment_variables         = optional(map(string))
    framework                     = optional(string)
    pull_request_environment_name = optional(string)
    stage                         = optional(string)
  })
  description = "The automated branch creation configuration for the Amplify app"
  default     = null
}

variable "auto_branch_creation_patterns" {
  type        = list(string)
  description = "The automated branch creation glob patterns for the Amplify app"
  default     = []
}

variable "basic_auth_credentials" {
  type        = string
  description = "The credentials for basic authorization for the Amplify app"
  default     = null
}

variable "build_spec" {
  type        = string
  description = <<-EOT
    The [build specification](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html) (build spec) for the Amplify app.
    If not provided then it will use the `amplify.yml` at the root of your project / branch.
    EOT
  default     = null
}

variable "enable_auto_branch_creation" {
  type        = bool
  description = "Enables automated branch creation for the Amplify app"
  default     = false
}

variable "enable_basic_auth" {
  type        = bool
  description = <<-EOT
    Enables basic authorization for the Amplify app.
    This will apply to all branches that are part of this app.
    EOT
  default     = false
}

variable "enable_branch_auto_build" {
  type        = bool
  description = "Enables auto-building of branches for the Amplify App"
  default     = true
}

variable "enable_branch_auto_deletion" {
  type        = bool
  description = "Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository"
  default     = false
}

variable "environment_variables" {
  type        = map(string)
  description = "The environment variables for the Amplify app"
  default     = {}
}

variable "iam_service_role_arn" {
  type        = list(string)
  description = <<-EOT
    The AWS Identity and Access Management (IAM) service role for the Amplify app.
    If not provided, a new role will be created if the variable `iam_service_role_enabled` is set to `true`.
    EOT
  default     = []
  nullable    = false
}

variable "iam_service_role_enabled" {
  type        = bool
  description = "Flag to create the IAM service role for the Amplify app"
  default     = false
  nullable    = false
}

variable "iam_service_role_actions" {
  type        = list(string)
  description = <<-EOT
    List of IAM policy actions for the AWS Identity and Access Management (IAM) service role for the Amplify app.
    If not provided, the default set of actions will be used for the role if the variable `iam_service_role_enabled` is set to `true`.
    EOT
  default     = []
  nullable    = false
}

variable "custom_rules" {
  type = list(object({
    condition = optional(string)
    source    = string
    status    = optional(string)
    target    = string
  }))
  description = "The custom rules to apply to the Amplify App"
  default     = []
  nullable    = false
}

variable "environments" {
  type = map(object({
    branch_name                   = optional(string)
    backend_enabled               = optional(bool, false)
    environment_name              = optional(string)
    deployment_artifacts          = optional(string)
    stack_name                    = optional(string)
    display_name                  = optional(string)
    description                   = optional(string)
    enable_auto_build             = optional(bool)
    enable_basic_auth             = optional(bool)
    enable_notification           = optional(bool)
    enable_performance_mode       = optional(bool)
    enable_pull_request_preview   = optional(bool)
    environment_variables         = optional(map(string))
    framework                     = optional(string)
    pull_request_environment_name = optional(string)
    stage                         = optional(string)
    ttl                           = optional(number)
    webhook_enabled               = optional(bool, false)
  }))
  description = "The configuration of the environments for the Amplify App"
  default     = {}
  nullable    = false
}

variable "domain_config" {
  type = object({
    domain_name            = optional(string)
    enable_auto_sub_domain = optional(bool, false)
    wait_for_verification  = optional(bool, false)
    sub_domain = list(object({
      branch_name = string
      prefix      = string
    }))
  })
  description = "Amplify custom domain configuration"
  default     = null
}

variable "certificate_verification_dns_record_enabled" {
  type        = bool
  description = <<-EOT
    Whether or not to create DNS records for SSL certificate validation.
    If using the DNS zone from `dns-delegated`, the SSL certificate is already validated, and this variable must be set to `false`.
    EOT
  default     = false
}

variable "subdomains_dns_records_enabled" {
  type        = bool
  description = "Whether or not to create DNS records for the Amplify app custom subdomains"
  default     = false
}

variable "dns_delegated_component_name" {
  type        = string
  description = "The component name of `dns-delegated`"
  default     = "dns-delegated"
}

variable "dns_delegated_environment_name" {
  type        = string
  description = "The environment name of `dns-delegated`"
  default     = "gbl"
}
