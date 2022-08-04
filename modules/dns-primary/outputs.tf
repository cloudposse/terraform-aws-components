output "zones" {
  value       = aws_route53_zone.root
  description = "DNS zones"
}

output "acms" {
  value       = { for k, v in module.acm : k => v.arn }
  description = "ACM certificates for domains"
}
