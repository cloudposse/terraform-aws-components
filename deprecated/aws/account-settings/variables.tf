variable "minimum_password_length" {
  type        = "string"
  description = "Minimum number of characters allowed in an IAM user password.  Integer between 6 and 128, per https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html"

  ## Same default as https://github.com/cloudposse/terraform-aws-iam-account-settings:
  default = "8"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  type        = "string"
  description = "Application or solution name (e.g. `app`)"
  default     = "account"
}

variable "enabled" {
  description = "Whether or not to create the IAM account alias"
  default     = "true"
}
