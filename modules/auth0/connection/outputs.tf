output "auth0_connection_id" {
  value       = auth0_connection.this[0].id
  description = "The Auth0 Connection ID"
}
