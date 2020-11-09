variable "region" {
  type        = string
  description = "AWS Region"
}

variable "zone_config" {
  description = "Zone config"
  type = list(object({
    subdomain = string
    zone_name = string
  }))
}
