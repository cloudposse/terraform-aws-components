variable "prod_name_servers" {
  type = "list"
}

resource "aws_route53_record" "prod_dns_zone_ns" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "prod"
  type    = "NS"
  ttl     = "30"
  records = ["${var.prod_name_servers}"]
}
