variable "region" {
  type        = string
  description = "AWS Region"
}

variable "billing_mode" {
  type        = string
  default     = "PROVISIONED"
  description = "DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST"
}

variable "read_capacity" {
  default     = 5
  description = "DynamoDB read capacity units"
}

variable "write_capacity" {
  default     = 5
  description = "DynamoDB write capacity units"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates the terraform state S3 bucket can be destroyed even if it contains objects. These objects are not recoverable."
  default     = false
}

variable "prevent_unencrypted_uploads" {
  type        = bool
  description = "Prevent uploads of unencrypted objects to S3"
  default     = true
}

variable "enable_server_side_encryption" {
  type        = bool
  description = "Enable DynamoDB and S3 server-side encryption"
  default     = true
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable DynamoDB point-in-time recovery"
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

variable "access_roles_enabled" {
  type        = bool
  description = "Enable creation of access roles. Set false for cold start (before account-map has been created)."
  default     = true
}

variable "trusted_github_repos" {
  type        = list(string)
  description = <<-EOT
    A list of GitHub repositories allowed to access this role.
    Format is either "orgName/repoName" or just "repoName",
    in which case "cloudposse" will be used for the "orgName".
    Wildcard ("*") is allowed for "repoName".
    EOT
}

variable "trusted_github_org" {
  type        = string
  description = "The GitHub organization unqualified repos are assumed to belong to. Keeps `*` from meaning all orgs and all repos."
}
