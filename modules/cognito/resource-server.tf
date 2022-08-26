locals {
  resource_server_default = [
    {
      name       = var.resource_server_name
      identifier = var.resource_server_identifier
      scope = [
        {
          scope_name        = var.resource_server_scope_name
          scope_description = var.resource_server_scope_description
      }]
    }
  ]

  # This parses var.user_groups which is a list of objects (map), and transforms it to a tuple of elements to avoid conflict with  the ternary and local.groups_default
  resource_servers_provided = [for e in var.resource_servers : {
    name       = lookup(e, "name", null)
    identifier = lookup(e, "identifier", null)
    scope      = lookup(e, "scope", [])
    }
  ]

  resource_servers = length(var.resource_servers) == 0 && (var.resource_server_name == null || var.resource_server_name == "") ? [] : (
    length(var.resource_servers) > 0 ? local.resource_servers_provided : local.resource_server_default
  )
}

resource "aws_cognito_resource_server" "resource" {
  count = local.enabled ? length(local.resource_servers) : 0

  name       = lookup(element(local.resource_servers, count.index), "name")
  identifier = lookup(element(local.resource_servers, count.index), "identifier")

  dynamic "scope" {
    for_each = lookup(element(local.resource_servers, count.index), "scope")
    content {
      scope_name        = lookup(scope.value, "scope_name")
      scope_description = lookup(scope.value, "scope_description")
    }
  }

  user_pool_id = join("", aws_cognito_user_pool.pool.*.id)
}
