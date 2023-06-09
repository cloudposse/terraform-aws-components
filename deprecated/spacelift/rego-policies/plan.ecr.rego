package spacelift

proposed := input.spacelift.run.type == "PROPOSED"

deny[reason] { not proposed; reason := resource_deletion[_] }
warn[reason] { proposed; reason := resource_deletion[_] }

resource_deletion[sprintf(message, [action, resource.address])] {
  message := "action '%s' requires human review (%s)"
  review  := {"delete"}
  types   := {"aws_ecr_repository"}
  resource := input.terraform.resource_changes[_]
  action   := resource.change.actions[_]
  review[action]
  types[resource.type]
}
