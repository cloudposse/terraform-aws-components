package spacelift

# This policy allows autodeploy if there are only new resources or updates.
# It requires manual intervention (approval) if any of the resources will be deleted.

# Usage:
# settings:
#   spacelift:
#     autodeploy: true
#       policies_by_name_enabled:
#       - plan.autodeployupdates

warn[sprintf(message, [action, resource.address])] {
  message := "action '%s' requires human review (%s)"
  review  := {"delete"}

  resource := input.terraform.resource_changes[_]
  action   := resource.change.actions[_]

  review[action]
}
