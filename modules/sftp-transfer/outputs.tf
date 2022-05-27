output "id" {
  description = "Module ID of the created example (not SFTP server ID)"
  value       = module.this.enabled ? module.this.id : null
}

output "transfer_endpoint" {
  description = "The endpoint of the Transfer Server"
  value       = module.this.enabled ? join("", aws_transfer_server.default.*.endpoint) : null
}

output "elastic_ips" {
  description = "Provisioned Elastic IPs"
  value       = module.this.enabled && var.eip_enabled ? aws_eip.sftp.*.id : null
}

output "host_key_fingerprint" {
  description = "This value contains the SHA256 hash of the server's host key. This value is equivalent to the output of the ssh-keygen -l -E SHA256 -f my-new-server-key command."
  value       = aws_transfer_server.default.*.host_key_fingerprint
}

output "server_id" {
  description = "Server ID of the Transfer Server"
  value       = aws_transfer_server.default.*.id
}

output "dns_host" {
  description = "Service discovery hostname pointing to the Transfer Server endpoint"
  value       = aws_route53_record.main.*.name
}