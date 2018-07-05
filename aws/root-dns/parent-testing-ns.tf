variable "testing_name_servers" {
  type = "list"
}

resource "aws_route53_record" "testing_dns_zone_ns" {
  count   = "${signum(length(var.testing_name_servers))}"
  zone_id = "${aws_route53_zone.parent_dns_zone.zone_id}"
  name    = "testing"
  type    = "NS"
  ttl     = "30"
  records = ["${var.testing_name_servers}"]
}
