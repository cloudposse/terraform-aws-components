variable "aws_assume_role_arn" {
  type = "string"
}

variable "kops_iam_accounts_enabled" {
  type        = "list"
  description = "Accounts to create an IAM role and group for Kops users"
  default     = ["dev", "staging", "prod", "testing"]
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}
