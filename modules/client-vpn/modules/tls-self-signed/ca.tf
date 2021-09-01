# Certificate Authority

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "${module.this.id}.vpn.ca"
    organization = var.organization_name
  }

  validity_period_hours = var.ttl
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

