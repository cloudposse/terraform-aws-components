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
  default     = []
}

variable "tags" {
  type        = "map"
  description = "Additional tags (_e.g._ map(\"BusinessUnit\",\"ABC\")"
  default     = {}
}

variable "region" {
  description = "If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
  default     = ""
}

variable "flow_logs_enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}
