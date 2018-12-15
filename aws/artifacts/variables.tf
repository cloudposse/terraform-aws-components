variable "aws_assume_role_arn" {
  type        = "string"
  description = "The ARN of the role to assume"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  description = "Name  (e.g. `app` or `db`)"
  type        = "string"
  default     = "artifacts"
}

variable "enabled" {
  description = "Set to `false` to prevent the module from creating any resources"
  default     = "true"
}
