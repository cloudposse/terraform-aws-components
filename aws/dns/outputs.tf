output "zone_id" {
  value = "${aws_route53_zone.default.zone_id}"
}

output "name_servers" {
  value = "${aws_route53_zone.default.name_servers}"
}
