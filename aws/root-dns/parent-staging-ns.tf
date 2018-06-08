variable "staging_name_servers" {
  type = "list"
}

resource "aws_route53_record" "staging_dns_zone_ns" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "staging"
  type    = "NS"
  ttl     = "30"
  records = ["${var.staging_name_servers}"]
}
