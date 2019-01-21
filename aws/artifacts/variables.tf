variable "aws_assume_role_arn" {
  type        = "string"
  description = "The ARN of the role to assume"
}

variable "domain_name" {
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

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "aws_account_id" {
  type        = "string"
  description = "AWS account ID"
}
