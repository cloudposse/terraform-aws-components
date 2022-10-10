locals {
  sops_yaml     = yamldecode(data.sops_file.source.raw)
  secret_params = nonsensitive(local.sops_yaml[var.sops_source_key])

  secret_params_normalized = {
    for key, value in local.secret_params :
    key => {
      name        = key
      value       = value
      description = "SecureString param created from ssm-parameters component from SOPS source file: ${var.sops_source_file} from key at ${var.sops_source_key}"
      overwrite   = true
      type        = "SecureString"
    }
  }

  params     = var.enabled ? merge(var.params, local.secret_params_normalized) : {}
  param_keys = keys(local.params)
}

data "sops_file" "source" {
  source_file = "${path.root}/${var.sops_source_file}"
}

resource "aws_ssm_parameter" "destination" {
  for_each = local.params

  name        = each.key
  description = each.value.description
  type        = each.value.type
  key_id      = var.kms_arn
  value       = each.value.value
  overwrite   = each.value.overwrite

  tags = module.this.tags
}
