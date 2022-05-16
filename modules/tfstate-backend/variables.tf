variable "region" {
  description = "AWS Region"
  type        = string
}

variable "force_destroy" {
  description = "A boolean that indicates the terraform state S3 bucket can be destroyed even if it contains objects. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "prevent_unencrypted_uploads" {
  description = "Prevent uploads of unencrypted objects to S3"
  type        = bool
  default     = false
}

variable "enable_server_side_encryption" {
  description = "Enable DynamoDB and S3 server-side encryption"
  type        = bool
  default     = true
}

variable "enable_point_in_time_recovery" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = false
}

variable "access_roles" {
  description = "Map of access roles to create (key is role name, use \"default\" for same as component). See iam-assume-role-policy module for details."
  type = map(object({
    write_enabled           = bool
    allowed_roles           = map(list(string))
    denied_roles            = map(list(string))
    allowed_principal_arns  = list(string)
    denied_principal_arns   = list(string)
    allowed_permission_sets = map(list(string))
    denied_permission_sets  = map(list(string))
  }))
  default = {}
}
