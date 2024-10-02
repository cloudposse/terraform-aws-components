# AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  type        = string
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "ssm_enabled" {
  type        = bool
  default     = false
  description = "If `true` create SSM keys for the database user and password."
}

variable "ssm_key_format" {
  type        = string
  default     = "/%v/%v/%v"
  description = "SSM path format. The values will will be used in the following order: `var.ssm_key_prefix`, `var.name`, `var.ssm_key_*`"
}

variable "ssm_key_prefix" {
  type        = string
  default     = "ecs-service"
  description = "SSM path prefix. Omit the leading forward slash `/`."
}

locals {
  ssm_enabled = module.this.enabled && var.ssm_enabled

  url_params = { for i, url in local.full_urls : format(var.ssm_key_format, var.ssm_key_prefix, var.name, "url/${i}") => {
    description = "ECS Service URL for ${var.name}"
    type        = "String",
    value       = url
    }
  }

  params = merge({}, local.url_params)

  # Use the format for any other params we need to create
  # params = {
  #   "${format(var.ssm_key_format, var.ssm_key_prefix, var.name, "name")}" = {
  #     description = "ECS Service [name here] for ${var.name}"
  #     type        = "String",
  #     value       = "some value"
  #   },
  # }
}

resource "aws_ssm_parameter" "full_urls" {
  for_each = local.ssm_enabled ? local.params : {}

  name        = each.key
  description = each.value.description
  type        = each.value.type
  key_id      = var.kms_alias_name_ssm
  value       = each.value.value
  overwrite   = true

  tags = module.this.tags
}


output "ssm_key_prefix" {
  value       = local.ssm_enabled ? format(var.ssm_key_format, var.ssm_key_prefix, var.name, "") : null
  description = "SSM prefix"
}

output "ssm_parameters" {
  description = "SSM parameters for the ECS Service"
  value       = local.ssm_enabled ? keys(local.params) : []
}
