variable "local_name_servers" {
  type = "list"
}

resource "aws_route53_record" "local_dns_zone_ns" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "local"
  type    = "NS"
  ttl     = "30"
  records = ["${var.local_name_servers}"]
}
