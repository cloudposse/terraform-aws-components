output "application_load_balancer_protections" {
  description = "AWS Shield Advanced Protections for ALBs"
  value       = aws_shield_protection.alb_shield_protection
}

output "cloudfront_distribution_protections" {
  description = "AWS Shield Advanced Protections for CloudFront Distributions"
  value       = aws_shield_protection.cloudfront_shield_protection
}

output "elastic_ip_protections" {
  description = "AWS Shield Advanced Protections for Elastic IPs"
  value       = aws_shield_protection.eip_shield_protection
}

output "route53_hosted_zone_protections" {
  description = "AWS Shield Advanced Protections for Route53 Hosted Zones"
  value       = aws_shield_protection.route53_zone_protection
}
