output "id" {
  value       = module.acm.id
  description = "The ID of the certificate"
}

output "arn" {
  value       = module.acm.arn
  description = "The ARN of the certificate"
}

output "domain_validation_options" {
  value       = module.acm.domain_validation_options
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}

output "domain_name" {
  value       = local.enabled ? local.domain_name : null
  description = "Certificate domain name"
}
