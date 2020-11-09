# This file is included by default in terraform plans

enabled = true

# The maximum session duration (in seconds) that you want to set for the IAM roles.
# If you do not specify a value for this setting, the default maximum of one hour is applied.
# This setting can have a value from 1 hour (3600) to 12 hours (43200)
iam_role_max_session_duration = 43200

default_account_role_policy_arns = {
  # Default IAM Policy ARNs to attach to each role, can be overridden per account
  admin     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  ops       = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  poweruser = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  observer  = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
  terraform = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  helm      = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

# By default, all delegated roles in "identity" get created in other accounts.
# Roles in the exclude_roles list are not created.
exclude_roles = []

# Before roles are created, they cannot be given permission to access other roles.
# In general, we do not need roles in delegated accounts to be able to assume other
# roles in delegated accounts, so this is not a problem. However, we want to allow
# this is in root, so we have a flag we can change after the roles are created.
allow_same_account_assume_role = false
