output "ca_private_key_pem" {
    value       = tls_private_key.ca.private_key_pem
    description = "Self-signed Certificate Authority private key"
}

output "ca_cert_pem" {
    value       = tls_self_signed_cert.ca.cert_pem
    description = "Self-signed Certificate Authority certificate file"
}

output "root_private_key_pem" {
    value       = tls_private_key.root.private_key_pem
    description = "Self-signed Root certificate private key"
}

output "root_cert_pem" {
    value       = tls_locally_signed_cert.root.cert_pem
    description = "Self-signed Root certificate file"
}

output "server_private_key_pem" {
    value       = tls_private_key.server.private_key_pem
    description = "Self-Signed server private key"
}

output "server_cert_pem" {
    value       = tls_locally_signed_cert.server.cert_pem
    description = "Self-signed server certificate file"
}
