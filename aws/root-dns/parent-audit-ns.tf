variable "audit_name_servers" {
  type = "list"
}

resource "aws_route53_record" "audit_dns_zone_ns" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "audit"
  type    = "NS"
  ttl     = "30"
  records = ["${var.audit_name_servers}"]
}
