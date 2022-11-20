variable "region" {
  type        = string
  description = "AWS Region"
}

variable "quotas" {
  type = map(object({
    service_name = optional(string)
    service_code = optional(string)
    quota_name   = optional(string)
    quota_code   = optional(string)
    value        = number
  }))
  description = <<-EOT
    Map of quotas to set. Map keys are arbitrary and are used to allow Atmos to merge configurations.
    Delete an inherited quota by setting its key's value to null.
    You only need to provide one of either name or code for each of "service" and "quota".
    If you provide both, the code will be used.
    EOT
  default     = {}
}
