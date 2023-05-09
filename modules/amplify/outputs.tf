output "name" {
  description = "Amplify App name"
  value       = module.amplify_app.name
}

output "arn" {
  description = "Amplify App ARN "
  value       = module.amplify_app.arn
}

output "default_domain" {
  description = "Amplify App domain (non-custom)"
  value       = module.amplify_app.default_domain
}

output "backend_environments" {
  description = "Created backend environments"
  value       = module.amplify_app.backend_environments
}

output "branch_names" {
  description = "The names of the created Amplify branches"
  value       = module.amplify_app.branch_names
}

output "webhooks" {
  description = "Created webhooks"
  value       = module.amplify_app.webhooks
}

output "domain_association_arn" {
  description = "ARN of the domain association"
  value       = module.amplify_app.domain_association_arn
}

output "domain_association_certificate_verification_dns_record" {
  description = "The DNS record for certificate verification"
  value       = module.amplify_app.domain_association_certificate_verification_dns_record
}

output "sub_domains" {
  description = "DNS records and the verified status for the subdomains"
  value       = module.amplify_app.sub_domains
}
