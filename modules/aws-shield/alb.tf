data "aws_alb" "alb" {
  for_each = local.alb_protection_enabled ? toset(var.alb_names) : []

  name = each.key
}

resource "aws_shield_protection" "alb_shield_protection" {
  for_each = local.alb_protection_enabled ? data.aws_alb.alb : {}

  name         = data.aws_alb.alb[each.key].name
  resource_arn = data.aws_alb.alb[each.key].arn

  tags = local.tags
}
