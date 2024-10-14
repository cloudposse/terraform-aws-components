locals {
  ssm_enabled = local.enabled && var.ssm_enabled
}

resource "aws_ssm_parameter" "tunnel1_preshared_key" {
  count = local.ssm_enabled && local.preshared_key_enabled ? 1 : 0

  name        = format("%s/%s", var.ssm_path_prefix, "tunnel1_preshared_key")
  value       = local.tunnel1_preshared_key
  description = format("Preshared Key for Tunnel1 in the %s Site-to-Site VPN connection", module.this.id)
  type        = "SecureString"

  tags = module.this.tags
}

resource "aws_ssm_parameter" "tunnel2_preshared_key" {
  count = local.ssm_enabled && local.preshared_key_enabled ? 1 : 0

  name        = format("%s/%s", var.ssm_path_prefix, "tunnel2_preshared_key")
  value       = local.tunnel2_preshared_key
  description = format("Preshared Key for Tunnel2 in the %s Site-to-Site VPN connection", module.this.id)
  type        = "SecureString"

  tags = module.this.tags
}
