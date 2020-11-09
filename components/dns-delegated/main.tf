locals {
  zone_map = zipmap(var.zone_config[*].subdomain, var.zone_config[*].zone_name)
}

resource "aws_route53_zone" "default" {
  for_each = local.zone_map
  provider = aws.delegated

  name    = format("%s.%s", each.key, each.value)
  comment = format("DNS zone for %s.%s", each.key, each.value)
  tags    = module.this.tags
}

resource "aws_route53_record" "soa" {
  for_each = aws_route53_zone.default
  provider = aws.delegated

  allow_overwrite = true
  name            = aws_route53_zone.default[each.key].name
  type            = "SOA"
  ttl             = "60"
  zone_id         = aws_route53_zone.default[each.key].zone_id

  records = [
    "${aws_route53_zone.default[each.key].name_servers[0]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}

data "aws_route53_zone" "root_zone" {
  for_each = local.zone_map
  provider = aws.primary

  name         = format("%s.", each.value)
  private_zone = false
}

resource "aws_route53_record" "root_ns" {
  for_each = data.aws_route53_zone.root_zone
  provider = aws.primary

  allow_overwrite = true
  name            = each.key
  records         = aws_route53_zone.default[each.key].name_servers
  type            = "NS"
  ttl             = "30"
  zone_id         = data.aws_route53_zone.root_zone[each.key].zone_id
}
