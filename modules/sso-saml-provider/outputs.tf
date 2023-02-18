output "url" {
  value       = local.enabled ? local.url : null
  description = "Identity Provider Single Sign-On URL"
  sensitive   = true
}

output "ca" {
  value       = local.enabled ? local.ca : null
  description = "Raw signing certificate"
  sensitive   = true
}

output "issuer" {
  value       = local.enabled ? local.issuer : null
  description = "Identity Provider Single Sign-On Issuer URL"
  sensitive   = true
}

