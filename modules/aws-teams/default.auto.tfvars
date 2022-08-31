# This file is included by default in terraform plans

# Generally we set `enabled = false` for components like this one
# which are not intended to be deployed to multiple accounts,
# but this module is a very special case and it
# does not support  `enabled = false`.

enabled = true
