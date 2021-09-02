variable "aws_assume_role_arn" {
  type = "string"
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter between `name`, `namespace`, `stage` and `attributes`"
}

variable "attributes" {
  type        = "list"
  description = "Additional attributes (_e.g._ \"1\")"
  default     = ["executor"]
}

variable "tags" {
  type        = "map"
  description = "Additional tags (_e.g._ map(\"BusinessUnit\",\"ABC\")"
  default     = {}
}

variable "administrator_role_arn" {
  description = "IAM Role for the CloudFormation administrator account"
}
