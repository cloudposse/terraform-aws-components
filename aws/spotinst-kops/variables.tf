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

variable "chamber_name_token" {
  type        = string
  default     = "spotinst_token"
  description = "Chamber parameter name store Spotinst token"
}

variable "override_token" {
  type        = string
  default     = ""
  description = "Override Spotinst token"
}

variable "zone_name" {
  type        = string
  description = "DNS zone name"
}

variable "instance_types" {
  type        = list(string)
  default     = ["c4.2xlarge", "c4.large", "c4.4xlarge", "c4.8xlarge", "c4.xlarge", "c5.9xlarge", "c5.large", "c5.metal", "c5.2xlarge", "c5.4xlarge", "c5.xlarge", "c5.24xlarge", "c5.12xlarge", "c5.18xlarge", "c5d.4xlarge", "c5d.large", "c5d.18xlarge", "c5d.9xlarge", "c5d.xlarge", "c5d.2xlarge", "d2.4xlarge", "d2.xlarge", "d2.2xlarge", "d2.8xlarge", "g3.16xlarge", "g3.8xlarge", "g3.4xlarge", "g3s.xlarge", "g4dn.12xlarge", "g4dn.16xlarge", "g4dn.2xlarge", "g4dn.4xlarge", "g4dn.8xlarge", "g4dn.xlarge", "i3.large", "i3.16xlarge", "i3.xlarge", "i3.4xlarge", "i3.8xlarge", "i3.2xlarge", "i3en.12xlarge", "i3en.24xlarge", "i3en.2xlarge", "i3en.3xlarge", "i3en.6xlarge", "i3en.large", "i3en.xlarge", "m4.large", "m4.xlarge", "m4.16xlarge", "m4.2xlarge", "m4.4xlarge", "m4.10xlarge", "m5.large", "m5.16xlarge", "m5.12xlarge", "m5.24xlarge", "m5.2xlarge", "m5.4xlarge", "m5.xlarge", "m5.8xlarge", "m5.metal", "m5a.12xlarge", "m5a.16xlarge", "m5a.24xlarge", "m5a.2xlarge", "m5a.4xlarge", "m5a.8xlarge", "m5a.large", "m5a.xlarge", "m5ad.12xlarge", "m5ad.24xlarge", "m5ad.2xlarge", "m5ad.4xlarge", "m5ad.large", "m5ad.xlarge", "m5d.8xlarge", "m5d.16xlarge", "m5d.xlarge", "m5d.4xlarge", "m5d.12xlarge", "m5d.24xlarge", "m5d.2xlarge", "m5d.large", "m5d.metal", "p3.16xlarge", "p3.8xlarge", "p3.2xlarge", "r4.xlarge", "r4.16xlarge", "r4.large", "r4.4xlarge", "r4.8xlarge", "r4.2xlarge", "r5.8xlarge", "r5.metal", "r5.24xlarge", "r5.2xlarge", "r5.large", "r5.4xlarge", "r5.16xlarge", "r5.12xlarge", "r5.xlarge", "r5a.12xlarge", "r5a.16xlarge", "r5a.24xlarge", "r5a.2xlarge", "r5a.4xlarge", "r5a.8xlarge", "r5a.large", "r5a.xlarge", "r5ad.12xlarge", "r5ad.24xlarge", "r5ad.2xlarge", "r5ad.4xlarge", "r5ad.large", "r5ad.xlarge", "r5d.4xlarge", "r5d.8xlarge", "r5d.12xlarge", "r5d.xlarge", "r5d.16xlarge", "r5d.24xlarge", "r5d.metal", "r5d.2xlarge", "r5d.large", "t2.xlarge", "t2.large", "t2.small", "t2.medium", "t2.2xlarge", "t2.micro", "t3.xlarge", "t3.large", "t3.small", "t3.medium", "t3.micro", "t3.2xlarge", "t3a.xlarge", "t3a.2xlarge", "t3a.large", "t3a.medium", "t3a.small", "t3a.micro", "z1d.6xlarge", "z1d.3xlarge", "z1d.12xlarge", "z1d.large", "z1d.2xlarge", "z1d.xlarge"]
  description = "Instance types allowed in the Ocean cluster."
}

variable "spotinst_account_id" {
}

variable "spotinst_token" {
}

