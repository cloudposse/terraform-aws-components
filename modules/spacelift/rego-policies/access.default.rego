package spacelift

# Access Policy Documentation:
# https://docs.spacelift.io/concepts/policy/stack-access-policy

# TODO: Provide access to different users to different stacks depending on user permissions
# For example, you can give READ access to Spacelift stacks to the "data" team by using this Rego block
# read {
#	input.session.teams[_] == "data"
# }

# By default, allow WRITE access to everybody who has permissions to login to Spacelift
write {
  true
}
