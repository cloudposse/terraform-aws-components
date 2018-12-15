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
  description = "Name  (e.g. `app` or `db`)"
  type        = "string"
  default     = "artifacts"
}

variable "enabled" {
  description = "Set to `false` to prevent the module from creating any resources"
  default     = "true"
}
