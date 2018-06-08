variable "dev_name_servers" {
  type = "list"
}

resource "aws_route53_record" "dev_dns_zone_ns" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "dev"
  type    = "NS"
  ttl     = "30"
  records = ["${var.dev_name_servers}"]
}
