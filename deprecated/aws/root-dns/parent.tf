variable "parent_domain_name" {
  type        = "string"
  description = "Parent domain name"
}

resource "aws_route53_zone" "parent_dns_zone" {
  name    = "${var.parent_domain_name}"
  comment = "Parent domain name"
}

resource "aws_route53_record" "parent_dns_zone_soa" {
  allow_overwrite = true
  zone_id         = "${aws_route53_zone.parent_dns_zone.id}"
  name            = "${aws_route53_zone.parent_dns_zone.name}"
  type            = "SOA"
  ttl             = "60"

  records = [
    "${aws_route53_zone.parent_dns_zone.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

output "parent_zone_id" {
  value = "${aws_route53_zone.parent_dns_zone.zone_id}"
}

output "parent_name_servers" {
  value = "${aws_route53_zone.parent_dns_zone.name_servers}"
}
