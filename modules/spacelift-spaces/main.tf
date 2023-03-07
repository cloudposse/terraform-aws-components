resource "spacelift_space" "stage" {
  for_each = toset(local.stages)

  name        = each.key
  description = "This a child of the `root` space. It contains all the resources common to the `${each.key}` infrastructure.  (Managed by Terraform)."

  # Every account has a root space that serves as the root for the space tree.
  # Except for the root space, all the other spaces must define their parents
  parent_space_id  = "root"
  inherit_entities = true
}

resource "spacelift_space" "account" {
  for_each = local.account_info_map

  name        = each.key
  description = "This is a child of the `${each.value.stage}` space. It contains all the resources common to the `${each.key}` infrastructure. (Managed by Terraform)."

  parent_space_id  = spacelift_space.stage[each.value.stage].id
  inherit_entities = true

  depends_on = [
    spacelift_space.stage
  ]
}

locals {
  spacelift_spaces = distinct(concat(
    local.stages,
    [for k, v in local.account_info_map : lower(k)]
  ))

  okta_spacelift_app_label = "Spacelift"
}

resource "okta_group" "space_read" {
  for_each = var.okta_group_creation_enabled ? toset(local.spacelift_spaces) : []

  name        = "${var.okta_group_prefix}${each.key}-read"
  description = "Read access to Spacelift Stacks in the `${each.key}` Spacelift Space. (Managed by Terraform)."
}

resource "okta_group" "space_write" {
  for_each = var.okta_group_creation_enabled ? toset(local.spacelift_spaces) : []

  name        = "${var.okta_group_prefix}${each.key}-write"
  description = "Write access to Spacelift Stacks in the `${each.key}` Spacelift Space. (Managed by Terraform)."
}

data "okta_app" "spacelift" {
  label = local.okta_spacelift_app_label
}

resource "okta_app_group_assignments" "space_read" {
  app_id = data.okta_app.spacelift.id
  dynamic "group" {
    for_each = okta_group.space_read
    content {
      id = group.value.id
    }
  }
}

resource "okta_app_group_assignments" "space_write" {
  app_id = data.okta_app.spacelift.id
  dynamic "group" {
    for_each = okta_group.space_write
    content {
      id = group.value.id
    }
  }
}
