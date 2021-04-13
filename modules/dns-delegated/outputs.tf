output "zones" {
  value       = aws_route53_zone.default
  description = "Subdomain and zone config"
}

output "default_domain_name" {
  description = "Default root domain name (e.g. dev.example.net) for the cluster"
  value       = join(".", [var.zone_config[0].subdomain, var.zone_config[0].zone_name])
}

output "default_dns_zone_id" {
  description = "Default root DNS zone ID for the cluster"
  value       = aws_route53_zone.default[var.zone_config[0].subdomain].zone_id
}
