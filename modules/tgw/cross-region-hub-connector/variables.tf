variable "region" {
  type        = string
  description = "AWS Region"
}

variable "this_region" {
  type = object({
    tgw_stage_name  = string
    tgw_tenant_name = string
  })
  description = "Initiators region config. Describe the transit gateway that should originate the peering"
}

variable "home_region" {
  type = object({
    tgw_name_format = string
    tgw_stage_name  = string
    tgw_tenant_name = string
    region          = string
    environment     = string
  })
  description = "Acceptors region config. Describe the transit gateway that should accept the peering"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}
