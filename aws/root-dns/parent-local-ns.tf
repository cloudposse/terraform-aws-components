resource "aws_route53_record" "local_dns_name" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "local"
  type    = "A"
  ttl     = "30"
  records = ["127.0.0.1"]
}

resource "aws_route53_record" "local_dns_wildcard" {
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "*.local"
  type    = "A"
  ttl     = "30"
  records = ["127.0.0.1"]
}
