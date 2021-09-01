provider "awsutils" {
  region = "us-east-1"
}

module "tls_self_signed" {
  source = "./modules/tls-self-signed"

  organization_name = var.organization_name
}

resource "aws_acm_certificate" "ca" {
  private_key      = module.tls_self_signed.ca_private_key_pem
  certificate_body = module.tls_self_signed.ca_cert_pem
}

resource "aws_acm_certificate" "root" {
  private_key       = module.tls_self_signed.root_private_key_pem
  certificate_body  = module.tls_self_signed.root_cert_pem
  certificate_chain = module.tls_self_signed.ca_cert_pem
}

resource "aws_acm_certificate" "server" {
  private_key       = module.tls_self_signed.server_private_key_pem
  certificate_body  = module.tls_self_signed.server_cert_pem
  certificate_chain = module.tls_self_signed.ca_cert_pem
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = module.this.id
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.root.arn
  }

  connection_log_options {
    enabled               = var.logging_enabled
    cloudwatch_log_group  = var.logging_enabled ? aws_cloudwatch_log_group.vpn.name : null
    cloudwatch_log_stream = var.logging_enabled ? aws_cloudwatch_log_stream.vpn.name : null
  }

  tags = module.this.tags
}

resource "aws_ec2_client_vpn_network_association" "default" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  subnet_id              = var.aws_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "internal" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = var.aws_authorization_rule_target_cidr
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "internet_rule" {
  count = var.internet_access_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "internet_route" {
  count = var.internet_access_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.default.subnet_id
}

resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/vpn/${module.this.id}/logs"
  retention_in_days = var.logs_retention
  tags              = module.this.tags
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "${module.this.id}-vpn-usage"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}

resource "awsutils_export_client_config" "default" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  filename               = "${path.root}/vpn_config/${module.this.id}-client-config-final.ovpn"

  depends_on = [
    aws_ec2_client_vpn_endpoint.default,
    aws_ec2_client_vpn_network_association.default,
  ]
}

data "local_file" "client_config_file" {
  filename = "${path.root}/vpn_config/${module.this.id}-client-config-original.ovpn"

  depends_on = [
    null_resource.export_client_config
  ]
}

data "template_file" "client_config" {
  template = "${file("${path.module}/templates/client-config.ovpn.tpl")}"
  vars = {
    cert                   = module.tls_self_signed.root_cert_pem,
    private_key            = module.tls_self_signed.root_private_key_pem,
    original_client_config = data.local_file.client_config_file.content
  }
}
