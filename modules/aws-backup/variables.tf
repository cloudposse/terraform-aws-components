variable "region" {
  type        = string
  description = "AWS Region"
}

variable "kms_key_arn" {
  type        = string
  description = "The server-side encryption key that is used to protect your backups"
  default     = null
}

variable "backup_vault_lock_configuration" {
  type = object({
    changeable_for_days = optional(number)
    max_retention_days  = optional(number)
    min_retention_days  = optional(number)
  })
  description = <<-EOT
    The backup vault lock configuration, each vault can have one vault lock in place. This will enable Backup Vault Lock on an AWS Backup vault  it prevents the deletion of backup data for the specified retention period. During this time, the backup data remains immutable and cannot be deleted or modified."
    `changeable_for_days` - The number of days before the lock date. If omitted creates a vault lock in `governance` mode, otherwise it will create a vault lock in `compliance` mode.
  EOT
  default     = null
}

variable "selection_tags" {
  type        = list(map(string))
  description = "An array of tag condition objects used to filter resources based on tags for assigning to a backup plan"
  default     = []
}

variable "backup_resources" {
  type        = list(string)
  description = "An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan"
  default     = []
}

variable "plan_name_suffix" {
  type        = string
  description = "The string appended to the plan name"
  default     = null
}

variable "vault_enabled" {
  type        = bool
  description = "Whether or not a new Vault should be created"
  default     = true
}

variable "plan_enabled" {
  type        = bool
  description = "Whether or not to create a new Plan"
  default     = true
}

variable "iam_role_enabled" {
  type        = bool
  description = "Whether or not to create a new IAM Role and Policy Attachment"
  default     = true
}


variable "rules" {
  type = list(object({
    name                     = string
    schedule                 = optional(string)
    enable_continuous_backup = optional(bool)
    start_window             = optional(number)
    completion_window        = optional(number)
    lifecycle = optional(object({
      cold_storage_after                        = optional(number)
      delete_after                              = optional(number)
      opt_in_to_archive_for_supported_resources = optional(bool)
    }))
    copy_action = optional(object({
      destination_vault_arn = optional(string)
      lifecycle = optional(object({
        cold_storage_after                        = optional(number)
        delete_after                              = optional(number)
        opt_in_to_archive_for_supported_resources = optional(bool)
      }))
    }))
  }))
  description = "An array of rule maps used to define schedules in a backup plan"
  default     = []
}

variable "advanced_backup_setting" {
  type = object({
    backup_options = string
    resource_type  = string
  })
  description = "An object that specifies backup options for each resource type."
  default     = null
}
