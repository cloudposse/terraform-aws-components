variable "role_map" {
  type        = map(list(string))
  description = "Map of account:[role, role...]. Use `*` as role for entire account"
}

variable "permission_set_map" {
  type        = map(list(string))
  description = "Map of account:[PermissionSet, PermissionSet...] specifying AWS SSO PermissionSets when accessed from specified accounts"
  default     = {}
}

variable "iam_role_arn_template" {
  type        = string
  default     = "arn:%s:iam::%s:role/%s-%s-%s-%s"
  description = "IAM Role ARN template"
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = false
}

variable "aws_partition" {
  type        = string
  description = "The AWS \"partition\" to use when constructing ARNs"
  default     = "aws"
}

variable "global_environment_name" {
  type        = string
  description = "Global environment name"
  default     = "gbl"
}

variable "root_account_stage_name" {
  type        = string
  description = "The stage name for the root account"
  default     = "root"
}
