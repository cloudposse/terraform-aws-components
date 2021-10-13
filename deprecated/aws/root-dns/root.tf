variable "root_domain_name" {
  type        = "string"
  description = "Root domain name"
}

resource "aws_route53_zone" "root_dns_zone" {
  name    = "${var.root_domain_name}"
  comment = "DNS Zone for Root Account"
}

resource "aws_route53_record" "root_dns_zone_soa" {
  allow_overwrite = true
  zone_id         = "${aws_route53_zone.root_dns_zone.id}"
  name            = "${aws_route53_zone.root_dns_zone.name}"
  type            = "SOA"
  ttl             = "60"

  records = [
    "${aws_route53_zone.root_dns_zone.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

resource "aws_route53_record" "root_dns_zone_ns" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "root"
  type    = "NS"
  ttl     = "30"
  records = ["${aws_route53_zone.root_dns_zone.name_servers}"]
}

output "root_zone_id" {
  value = "${aws_route53_zone.root_dns_zone.zone_id}"
}

output "root_name_servers" {
  value = "${aws_route53_zone.root_dns_zone.name_servers}"
}
