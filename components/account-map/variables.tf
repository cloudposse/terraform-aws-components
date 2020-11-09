variable "region" {
  type        = string
  description = "AWS Region"
}

variable "root_account_aws_name" {
  type        = string
  description = "The name of the root account as reported by AWS"
}

variable "root_account_stage_name" {
  type        = string
  default     = "root"
  description = "The stage name for the root account"
}

variable "identity_account_stage_name" {
  type        = string
  default     = "identity"
  description = "The stage name for the account holding primary IAM roles"
}

variable "dns_account_stage_name" {
  type        = string
  default     = "dns"
  description = "The stage name for the primary DNS account"
}

variable "audit_account_stage_name" {
  type        = string
  default     = "audit"
  description = "The stage name for the audit account"
}

variable "iam_role_arn_template" {
  type        = string
  default     = "arn:aws:iam::%s:role/%s-%s-%s-%s"
  description = "IAM Role ARN template"
}
