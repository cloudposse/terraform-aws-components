variable "region" {
  type        = string
  description = "AWS Region"
}

variable "global_environment_name" {
  type        = string
  description = "Global environment name"
  default     = "gbl"
}

variable "region_abbreviation_type" {
  type        = string
  description = "Region abbreviation type, must be `to_fixed`, `to_short`, or `identity`"
  default     = "to_short"
}
