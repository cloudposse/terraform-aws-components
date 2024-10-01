variable "conformance_pack" {
  type        = string
  description = "The URL to a Conformance Pack"
}

variable "parameter_overrides" {
  type        = map(any)
  description = "A map of parameters names to values to override from the template"
  default     = {}
}
