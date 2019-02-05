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

variable "kops_readonly_role_name" {
  type        = "string"
  default     = "KopsReadOnly"
  description = "IAM role name for the Kubernetes readonly user, used by aws-iam-authenticator"
}

variable "kops_admin_role_name" {
  type        = "string"
  default     = "KopsAdmin"
  description = "IAM role name for the Kubernetes admin user, used by aws-iam-authenticator"
}
