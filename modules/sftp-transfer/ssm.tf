data "aws_ssm_parameter" "ssh_server_host_key" {
  count           = local.enabled && var.ssh_server_host_key_ssm_path != "" ? 1 : 0
  name            = var.ssh_server_host_key_ssm_path
  with_decryption = true
}