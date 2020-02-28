variable "aws_assume_role_arn" {
  type = string
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  default     = "spotinst"
  description = "Name"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter between `name`, `namespace`, `stage` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes (_e.g._ \"1\")"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ map(\"BusinessUnit\",\"ABC\")"
  default     = {}
}

variable "capabilities" {
  type        = list(string)
  description = "A list of capabilities. Valid values: CAPABILITY_IAM, CAPABILITY_NAMED_IAM, CAPABILITY_AUTO_EXPAND"
  default     = ["CAPABILITY_IAM"]
}

variable "chamber_format" {
  default     = "/%s/%s"
  description = "Format to store parameters in SSM, for consumption with chamber"
}

variable "chamber_service" {
  type        = string
  default     = "kops"
  description = "SSM parameter service name for use with chamber. This is used in chamber_format where /$chamber_service/$parameter would be the default."
}

variable "chamber_name_account_id" {
  type        = string
  default     = "spotinst_account_id"
  description = "Chamber parameter name store Spotinst account id"
}

variable "override_account_id" {
  type        = string
  default     = ""
  description = "Override Spotinst account id"
}

variable "chamber_name_external_id" {
  type        = string
  default     = "spotinst_external_id"
  description = "Chamber parameter name store Spotinst external id"
}

variable "override_external_id" {
  type        = string
  default     = ""
  description = "Override Spotinst external id"
}

variable "chamber_name_principal" {
  type        = string
  default     = "spotinst_principal"
  description = "Chamber parameter name store Spotinst principal"
}

variable "override_principal" {
  type        = string
  default     = ""
  description = "Override Spotinst principal"
}

variable "chamber_name_token" {
  type        = string
  default     = "spotinst_account_token"
  description = "Chamber parameter name store Spotinst account token"
}

variable "override_token" {
  type        = string
  default     = ""
  description = "Override Spotinst token"
}

