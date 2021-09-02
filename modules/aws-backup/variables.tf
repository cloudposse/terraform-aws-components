variable "region" {
  type        = string
  description = "AWS Region"
}

variable "kms_key_arn" {
  type        = string
  description = "The server-side encryption key that is used to protect your backups"
  default     = null
}

variable "schedule" {
  type        = string
  description = "A CRON expression specifying when AWS Backup initiates a backup job"
  default     = null
}

variable "start_window" {
  type        = number
  description = "The amount of time in minutes before beginning a backup. Minimum value is 60 minutes"
  default     = null
}

variable "completion_window" {
  type        = number
  description = "The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window`"
  default     = null
}

variable "cold_storage_after" {
  type        = number
  description = "Specifies the number of days after creation that a recovery point is moved to cold storage"
  default     = null
}

variable "delete_after" {
  type        = number
  description = "Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after`"
  default     = null
}

variable "destination_vault_arn" {
  type        = string
  description = "An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup"
  default     = null
}

variable "copy_action_cold_storage_after" {
  type        = number
  description = "For copy operation, specifies the number of days after creation that a recovery point is moved to cold storage"
  default     = null
}

variable "copy_action_delete_after" {
  type        = number
  description = "For copy operation, specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `copy_action_cold_storage_after`"
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

variable "target_vault_name" {
  type        = string
  description = "Override target Vault Name"
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

variable "target_iam_role_name" {
  type        = string
  description = "Override target IAM Name"
  default     = null
}
