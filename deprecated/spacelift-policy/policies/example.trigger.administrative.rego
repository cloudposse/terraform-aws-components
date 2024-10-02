# Local example policy taken from https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/trigger.administrative.rego

# https://www.openpolicyagent.org/docs/latest/policy-reference/#builtin-strings-stringsany_prefix_match

package spacelift

# Trigger the stack after it gets created in the `administrative` stack
trigger[stack.id] {
  stack := input.stacks[_]
  # compare a plaintext string (stack.id) to a checksum
  strings.any_suffix_match(crypto.sha256(stack.id), id_shas_of_created_stacks)
}

id_shas_of_created_stacks[change.entity.data.values.id] {
  change := input.run.changes[_]
  change.action == "added"
  change.entity.type == "spacelift_stack"
  change.phase == "apply" # The change has actually been applied, not just planned
}

sample { true }
