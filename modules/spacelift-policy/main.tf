locals {
  enabled = module.this.enabled

  # Get all policies without a URL
  # { k = { "body": "https://", etc } }
  policies_with_body = {
    for k, v in var.policies :
    # merge them with existing data structure
    k => merge(v, {
      # append body_append to each body if one exists
      "body" = format(
        join("\n", [
          "# NOTE: source of policy is in the stack YAML",
          "",
          "%s",
        ]),
        lookup(v, "body", file("${path.module}/${lookup(v, "body_path")}")),
      )
    })
    if lookup(v, "body", null) != null || lookup(v, "body_path", null) != null
  }

  # Get all policies with a URL
  # { k = "https://" }
  policies_with_body_url = {
    for k, v in var.policies :
    k => try(
      format(v["body_url"], var.policy_version),
      v["body_url"],
    )
    if lookup(v, "body_url", null) != null
  }

  # After downloading the bodies from the URLs
  # { k = { "body" = "...", etc } }
  policies_with_body_url_downloaded = {
    for k, v in local.policies_with_body_url :
    # merge them with existing data structure
    k => merge(var.policies[k], {
      # append body_append to each body if one exists
      "body" = format(
        join("\n", [
          "# NOTE: source url of policy: %s",
          "",
          "%s",
        ]),
        v,
        data.http.default[k]["body"],
      )
    }) if local.enabled
  }

  # TODO: get local policies

  # Merge all the policies together and create policies from this object
  all_policies = merge(
    local.policies_with_body,
    local.policies_with_body_url_downloaded,
  )

  # keep the object keys consistent to avoid terraform errors
  policies = {
    for k, v in local.all_policies :
    k => merge(
      # remove optional keys
      {
        for vk, vv in v :
        vk => vv
        if !contains([
          "name",
          "body_append",
          "body_url",
          "body_path",
          "labels",
          "space_id",
        ], vk)
      },
      # these were previously set in the spacelift_policy resource and moved here
      # to avoid terraform errors around inconsistent object keys
      {
        name     = lookup(v, "name", title(join(" ", split("-", k))))
        labels   = lookup(v, "labels", var.labels)
        space_id = lookup(v, "space_id", var.space_id)
        body = lookup(v, "body_append", "") == "" ? v["body"] : format(
          join("\n", [
            "%s",
            "",
            "# NOTE: below is appended to the original policy",
            "",
            "%s",
          ]),
          v["body"],
          lookup(v, "body_append", "")
        )
      },
    )
  }
}

data "http" "default" {
  for_each = local.enabled ? local.policies_with_body_url : {}
  url      = each.value
}

resource "spacelift_policy" "default" {
  for_each = local.enabled ? local.policies : {}

  name     = lookup(each.value, "name")
  body     = lookup(each.value, "body")
  type     = upper(lookup(each.value, "type"))
  labels   = lookup(each.value, "labels")
  space_id = lookup(each.value, "space_id")
}
