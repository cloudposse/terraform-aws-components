output "vpn_endpoint_id" {
  value       = aws_ec2_client_vpn_endpoint.default.id
  description = "The ID of the Client VPN Endpoint Connection."
}