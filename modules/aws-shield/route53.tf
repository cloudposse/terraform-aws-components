data "aws_route53_zone" "route53_zone" {
  for_each = local.route53_protection_enabled ? toset(var.route53_zone_names) : []

  name = each.key
}

resource "aws_shield_protection" "route53_zone_protection" {
  for_each = local.route53_protection_enabled ? data.aws_route53_zone.route53_zone : {}

  name         = data.aws_route53_zone.route53_zone[each.key].name
  resource_arn = "arn:${local.partition}:route53:::hostedzone/${data.aws_route53_zone.route53_zone[each.key].id}"

  tags = local.tags
}
