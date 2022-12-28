variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "allowed_roles" {
  type        = map(list(string))
  description = <<-EOT
    Map of account:[role, role...] specifying roles allowed to assume the role.
    Roles are symbolic names like `ops` or `terraform`. Use `*` as role for entire account.
    EOT
  default     = {}
}

variable "denied_roles" {
  type        = map(list(string))
  description = <<-EOT
    Map of account:[role, role...] specifying roles explicitly denied permission to assume the role.
    Roles are symbolic names like `ops` or `terraform`. Use `*` as role for entire account.
    EOT
  default     = {}
}

variable "allowed_principal_arns" {
  type        = list(string)
  description = "List of AWS principal ARNs allowed to assume the role."
  default     = []
}


variable "denied_principal_arns" {
  type        = list(string)
  description = "List of AWS principal ARNs explicitly denied access to the role."
  default     = []
}

variable "allowed_permission_sets" {
  type        = map(list(string))
  description = "Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets allowed to assume the role when coming from specified account"
  default     = {}
}

variable "denied_permission_sets" {
  type        = map(list(string))
  description = "Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets denied access to the role when coming from specified account"
  default     = {}
}

variable "iam_users_enabled" {
  type        = bool
  description = "True if you would like IAM Users to be able to assume the role."
  default     = false
}
