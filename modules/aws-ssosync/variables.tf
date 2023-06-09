variable "region" {
  type        = string
  description = "AWS Region where AWS SSO is enabled"
}

variable "schedule_expression" {
  type        = string
  description = "Schedule for trigger the execution of ssosync (see CloudWatch schedule expressions)"
  default     = "rate(15 minutes)"
}

variable "log_level" {
  type        = string
  description = "Log level for Lambda function logging"
  default     = "warn"

  validation {
    condition     = contains(["panic", "fatal", "error", "warn", "info", "debug", "trace"], var.log_level)
    error_message = "Allowed values: `panic`, `fatal`, `error`, `warn`, `info`, `debug`, `trace`"
  }
}

variable "log_format" {
  type        = string
  description = "Log format for Lambda function logging"
  default     = "json"

  validation {
    condition     = contains(["json", "text"], var.log_format)
    error_message = "Allowed values: `json`, `text`"
  }
}

variable "ssosync_url_prefix" {
  type        = string
  description = "URL prefix for ssosync binary"
  default     = "https://github.com/Benbentwo/ssosync/releases/download"
}

variable "ssosync_version" {
  type        = string
  description = "Version of ssosync to use"
  default     = "v2.0.2"
}

variable "architecture" {
  type        = string
  description = "Architecture of the Lambda function"
  default     = "x86_64"
}

variable "google_credentials_ssm_path" {
  type        = string
  description = "SSM Path for `ssosync` secrets"
  default     = "/ssosync"
}

variable "google_admin_email" {
  type        = string
  description = "Google Admin email"
}

variable "google_user_match" {
  type        = string
  description = "Google Workspace user filter query parameter, example: 'name:John* email:admin*', see: https://developers.google.com/admin-sdk/directory/v1/guides/search-users"
  default     = ""
}

variable "google_group_match" {
  type        = string
  description = "Google Workspace group filter query parameter, example: 'name:Admin* email:aws-*', see: https://developers.google.com/admin-sdk/directory/v1/guides/search-groups"
  default     = ""
}

variable "ignore_groups" {
  type        = string
  description = "Ignore these Google Workspace groups"
  default     = ""
}

variable "ignore_users" {
  type        = string
  description = "Ignore these Google Workspace users"
  default     = ""
}

variable "include_groups" {
  type        = string
  description = "Include only these Google Workspace groups. (Only applicable for sync_method user_groups)"
  default     = ""
}

variable "sync_method" {
  type        = string
  description = "Sync method to use"
  default     = "groups"

  validation {
    condition     = contains(["groups", "users_groups"], var.sync_method)
    error_message = "Allowed values: `groups`, `users_groups`"
  }
}
