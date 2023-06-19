locals {
  enabled = module.this.enabled
  spaces = local.enabled ? { for item in values(module.space)[*].space : item.name => {
    description      = item.description
    id               = item.id
    inherit_entities = item.inherit_entities
    labels           = toset(item.labels)
    parent_space_id  = item.parent_space_id
    }
  } : {}

  # Create a map of all the policies {policy_name = policy}
  policies = local.enabled ? { for item in distinct(values(module.policy)[*].policy) : item.name => {
    id       = item.id
    type     = item.type
    labels   = toset(item.labels)
    space_id = item.space_id
    }
  } : {}

  policy_inputs = local.enabled ? {
    for k, v in var.spaces : k => {
      for pn, p in v.policies : pn => {
        body             = p.body
        body_url         = p.body_url
        body_url_version = p.body_url_version
        labels           = toset(v.labels)
        name             = pn
        space_id         = k == "root" ? "root" : module.space[k].space_id
        type             = p.type
      }
    }
  } : {}
  all_policies_inputs = merge([for k, v in local.policy_inputs : v if length(keys(v)) > 0]...)
}

module "space" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-space"
  version = "1.0.0"

  # Create a space for each entry in the `spaces` variable, except for the root space which already exists by default
  # and cannot be deleted.
  for_each = { for k, v in var.spaces : k => v if k != "root" }

  space_name                   = each.key
  parent_space_id              = each.value.parent_space_id
  description                  = each.value.description
  inherit_entities_from_parent = each.value.inherit_entities
  labels                       = each.value.labels
}

module "policy" {
  source  = "cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-policy"
  version = "1.0.0"

  for_each = local.all_policies_inputs

  policy_name      = each.key
  body             = each.value.body
  body_url         = each.value.body_url
  body_url_version = each.value.body_url_version
  type             = each.value.type
  labels           = each.value.labels
  space_id         = each.value.space_id
}
