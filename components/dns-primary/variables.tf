variable "region" {
  type        = string
  description = "AWS Region"
}

variable "domain_names" {
  type        = list(string)
  default     = null
  description = "Root domain name list, e.g. `[\"breadgateway.net\"]`"
}

variable "record_config" {
  description = "DNS Record config"
  type = list(object({
    root_zone = string
    name      = string
    type      = string
    ttl       = string
    records   = list(string)
  }))
  default = []
}
