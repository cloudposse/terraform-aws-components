provider "awsutils" {
  region = "us-east-1"
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
  subnet_id              = var.subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "internal" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = var.authorization_rule_target_cidr
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

# the sed edit is to add 'asdf.' to the DNS entry 
# to make it work work for the OpenVPN Window's client (Mac also accepts this)
resource "null_resource" "export_client_config" {
  provisioner "local-exec" {
    command = <<-EOT
    mkdir -p ${path.root}/vpn_config/ && \
    aws ec2 export-client-vpn-client-configuration \
            --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.default.id} \
            --output text > ${path.root}/vpn_config/${module.this.id}-client-config-original.ovpn \
            --region ${var.region}
    sed -i ".backup" "s/remote cvpn/remote asdf.cvpn/g" ${path.root}/vpn_config/${module.this.id}-client-config-original.ovpn
    rm ${path.root}/vpn_config/${module.this.id}-client-config-original.ovpn.backup
EOT
  }

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
    cert                   = tls_locally_signed_cert.root.cert_pem,
    private_key            = tls_private_key.root.private_key_pem,
    original_client_config = data.local_file.client_config_file.content
  }
}

resource "local_file" "client_config" {
  filename        = "${path.root}/vpn_config/${module.this.id}-client-config-final.ovpn"
  file_permission = "0644"
  content         = data.template_file.client_config.rendered
}