output "auth0_client_id" {
  value       = auth0_client.this[0].client_id
  description = "The Auth0 Application Client ID"
}
