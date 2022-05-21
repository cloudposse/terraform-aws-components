locals {
  poweruser_access_permission_set = [{
    name             = "PowerUserAccess",
    description      = "Allow Poweruser access to the account",
    relay_state      = "",
    session_duration = "",
    tags             = {},
    inline_policy    = ""
    policy_attachments = [
      "arn:aws:iam::aws:policy/PowerUserAccess",
      "arn:aws:iam::aws:policy/AWSSupportAccess",
    ]
  }]
}
