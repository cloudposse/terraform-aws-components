locals {
  # This loops through all of the administrative stacks in the atmos config and extracts the space_name from the
  # spacelift.settings metadata. It then creates a set of all of the unique space_names so we can use that to look up
  # their IDs from remote state.
  unique_spaces_from_config = toset([for k, v in {
    for k, v in module.child_stacks_config.spacelift_stacks : k => try(
      coalesce(
        # if `space_name` is specified, use it
        v.settings.spacelift.space_name,
        # otherwise, try to replace the context tokens in `space_name_template` and use it
        # `space_name_template` accepts the following context tokens: {namespace}, {tenant}, {environment}, {stage}
        v.settings.spacelift.space_name_pattern != "" && v.settings.spacelift.space_name_pattern != null ? (
          replace(
            replace(
              replace(
                replace(
                  v.settings.spacelift.space_name_pattern,
                  "{namespace}", module.this.namespace
                ),
                "{tenant}", module.this.tenant
              ),
              "{environment}", module.this.environment
            ),
          "{stage}", module.this.stage)
        ) : ""
      ),
      "root"
    )
    if try(v.settings.spacelift.workspace_enabled, false) == true
  } : v if v != "root"])

  # Create a map of all the unique spaces {space_name = space_id}
  spaces = merge(try({
    for k in local.unique_spaces_from_config : k => module.spaces.outputs.spaces[k].id
    }, {}), {
    root = "root"
  })

  # Create a list of all the spaces that are defined in config but missing from Spacelift
  missing_spaces = setunion(setsubtract(local.unique_spaces_from_config, keys(local.spaces)))
}

# Ensure all of the spaces referenced in the Atmos config exist in Spacelift
resource "null_resource" "spaces_precondition" {
  count = local.enabled ? 1 : 0

  lifecycle {
    precondition {
      condition     = length(local.missing_spaces) == 0
      error_message = "Please create the following spaces in Spacelift before running this module: ${join(", ", local.missing_spaces)}"
    }
  }
}
