locals {
  billing_read_only_access_permission_set = [{
    name             = "BillingReadOnlyAccess",
    description      = "Allow users to view bills in the billing console",
    relay_state      = "",
    session_duration = "",
    tags             = {},
    inline_policy    = ""
    policy_attachments = [
      "arn:${local.aws_partition}:iam::aws:policy/AWSBillingReadOnlyAccess",
      "arn:${local.aws_partition}:iam::aws:policy/AWSSupportAccess",
    ]
    customer_managed_policy_attachments = []
  }]
}
