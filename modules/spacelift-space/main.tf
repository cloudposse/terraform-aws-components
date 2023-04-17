locals {
  enabled = module.this.enabled

  # keep the object keys consistent to avoid terraform errors
  spaces = {
    for k, v in var.spaces :
    k => {
      # these are set in the spacelift_policy resource and moved here
      # to avoid terraform errors around inconsistent object keys
      name             = lookup(v, "name", k)
      parent_space_id  = lookup(v, "parent_space_id", var.parent_space_id)
      inherit_entities = lookup(v, "inherit_entities", var.inherit_entities)
      description      = lookup(v, "description", var.description)
      labels           = lookup(v, "labels", var.labels)
    }
  }
}

resource "spacelift_space" "default" {
  for_each = local.enabled ? local.spaces : {}

  name             = each.value.name
  parent_space_id  = each.value.parent_space_id
  inherit_entities = each.value.inherit_entities
  description      = each.value.description
  labels           = each.value.labels
}
