data "aws_alb" "alb" {
  for_each = local.alb_protection_enabled == false ? [] : length(var.alb_names) > 0 ? toset(var.alb_names) : toset([module.alb[0].outputs.load_balancer_name])

  name = each.key
}

resource "aws_shield_protection" "alb_shield_protection" {
  for_each = local.alb_protection_enabled ? data.aws_alb.alb : {}

  name         = data.aws_alb.alb[each.key].name
  resource_arn = data.aws_alb.alb[each.key].arn

  tags = local.tags
}
