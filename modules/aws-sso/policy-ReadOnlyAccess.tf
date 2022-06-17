locals {
  read_only_access_permission_set = [{
    name             = "ReadOnlyAccess",
    description      = "Allow Read Only access to the account",
    relay_state      = "",
    session_duration = "",
    tags             = {},
    inline_policy    = ""
    policy_attachments = [
      "arn:${local.aws_partition}:iam::aws:policy/ReadOnlyAccess",
      "arn:${local.aws_partition}:iam::aws:policy/AWSSupportAccess",
    ]
  }]
}
