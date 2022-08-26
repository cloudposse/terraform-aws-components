locals {
  groups_default = [
    {
      name        = var.user_group_name
      description = var.user_group_description
      precedence  = var.user_group_precedence
      role_arn    = var.user_group_role_arn
    }
  ]

  # This parses var.user_groups which is a list of objects (map), and transforms it to a tuple of elements to avoid conflict with  the ternary and local.groups_default
  groups_provided = [for e in var.user_groups : {
    name        = lookup(e, "name", null)
    description = lookup(e, "description", null)
    precedence  = lookup(e, "precedence", null)
    role_arn    = lookup(e, "role_arn", null)
    }
  ]

  groups = length(var.user_groups) == 0 && (var.user_group_name == null || var.user_group_name == "") ? [] : (
    length(var.user_groups) > 0 ? local.groups_provided : local.groups_default
  )
}

resource "aws_cognito_user_group" "main" {
  count = local.enabled ? length(local.groups) : 0

  name         = lookup(element(local.groups, count.index), "name")
  description  = lookup(element(local.groups, count.index), "description")
  precedence   = lookup(element(local.groups, count.index), "precedence")
  role_arn     = lookup(element(local.groups, count.index), "role_arn")
  user_pool_id = join("", aws_cognito_user_pool.pool.*.id)
}
