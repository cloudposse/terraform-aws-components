locals {
  tunnel1_preshared_key = length(var.vpn_connection_tunnel1_preshared_key) > 0 ? var.vpn_connection_tunnel1_preshared_key : join("", random_password.tunnel1_preshared_key[*].result)
  tunnel2_preshared_key = length(var.vpn_connection_tunnel2_preshared_key) > 0 ? var.vpn_connection_tunnel2_preshared_key : join("", random_password.tunnel2_preshared_key[*].result)
}

resource "random_password" "tunnel1_preshared_key" {
  count = length(var.vpn_connection_tunnel1_preshared_key) > 0 ? 0 : 1

  length = 60
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"
}

resource "random_password" "tunnel2_preshared_key" {
  count = length(var.vpn_connection_tunnel2_preshared_key) > 0 ? 0 : 1

  length = 60
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"
}

resource "aws_ssm_parameter" "tunnel1_preshared_key" {
  count = length(var.vpn_connection_tunnel1_preshared_key) > 0 ? 0 : 1

  name        = format("%s/%s", var.ssm_path_prefix, "tunnel1_preshared_key")
  value       = local.tunnel1_preshared_key
  description = format("Preshared Key for Tunnel1 in the %s Site-to-Site VPN connection", module.this.id)
  type        = "SecureString"

  tags = module.this.tags
}

resource "aws_ssm_parameter" "tunnel2_preshared_key" {
  count = length(var.vpn_connection_tunnel2_preshared_key) > 0 ? 0 : 1

  name        = format("%s/%s", var.ssm_path_prefix, "tunnel2_preshared_key")
  value       = local.tunnel2_preshared_key
  description = format("Preshared Key for Tunnel2 in the %s Site-to-Site VPN connection", module.this.id)
  type        = "SecureString"

  tags = module.this.tags
}
