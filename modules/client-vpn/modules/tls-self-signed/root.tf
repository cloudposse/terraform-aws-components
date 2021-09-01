# Root Certificate

resource "tls_private_key" "root" {
  algorithm = "RSA"
}

resource "tls_cert_request" "root" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name  = "${module.this.id}.vpn.client"
    organization = var.organization_name
  }
}

resource "tls_locally_signed_cert" "root" {
  cert_request_pem   = tls_cert_request.root.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.ttl

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

