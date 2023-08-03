locals {
  alb_arns      = concat(local.alb_name_arns, local.alb_tag_arns)
  alb_name_arns = [for alb_instance in data.aws_alb.alb : alb_instance.arn]
  alb_tag_arns  = flatten([for alb_instance in data.aws_lbs.alb_by_tags : alb_instance.arns])
}

data "aws_alb" "alb" {
  for_each = toset(var.alb_names)
  name     = each.key
}

data "aws_lbs" "alb_by_tags" {
  for_each = { for i, v in var.alb_tags : i => v }
  tags     = each.value
}
