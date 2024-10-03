locals {
  # If you have custom permission sets, override this declaration by creating
  # a file called `additional-permission-sets_override.tf`.
  # Then add the custom permission sets to the overridable_additional_permission_sets in that file.
  # See the README for more details.
  overridable_additional_permission_sets = [
    # Example
    # local.audit_manager_permission_set,
  ]
}
