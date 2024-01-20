variable "region" {
  type        = string
  description = "AWS Region"
}

variable "registry_name" {
  type        = string
  description = "Glue registry name. If not provided, the name will be generated from the context"
  default     = null
}

variable "registry_description" {
  type        = string
  description = "Glue registry description"
  default     = null
}
