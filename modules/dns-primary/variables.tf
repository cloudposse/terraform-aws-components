variable "region" {
  type        = string
  description = "AWS Region"
}

variable "domain_names" {
  type        = list(string)
  default     = null
  description = "Root domain name list, e.g. `[\"example.net\"]`"
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

# zone_ids can be found here: https://docs.aws.amazon.com/general/latest/gr/elb.html 
variable "alias_record_config" {
  description = "DNS Alias Record config"
  type = list(object({
    root_zone     = string
    name          = string
    type          = string
    zone_id       = string
    record        = string
    target_health = string
  }))
  default = []
}

variable "dns_soa_config" {
  type        = string
  default     = "awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  description = "Root domain name DNS SOA record"
}