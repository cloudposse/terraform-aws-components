output "zones" {
  value       = local.aws_route53_zone
  description = "Subdomain and zone config"
}

output "default_domain_name" {
  description = "Default root domain name (e.g. dev.example.net) for the cluster"
  value       = join(".", [var.zone_config[0].subdomain, var.zone_config[0].zone_name])
}

output "default_dns_zone_id" {
  description = "Default root DNS zone ID for the cluster"
  value       = local.aws_route53_zone[var.zone_config[0].subdomain].zone_id
}

output "route53_hosted_zone_protections" {
  description = "List of AWS Shield Advanced Protections for Route53 Hosted Zones."
  value       = aws_shield_protection.shield_protection
}
