# This Terraform configuration file which creates a customer-managed policy exists in both iam-primary-roles and iam-delegated-roles.
#
# The reason for this is as follows:
#
# When iam-primary-roles creates this policy and allows it to be referenced by its short name in its configuration,
# it also exports its configuration such that it can be consumed by iam-delegated-roles.
# The latter component will then attempt to attach this customer-managed policy as per the exported configuration.
#
# Because of this, the iam-delegated-roles component needs to both create this same policy in the target account and map the short name to it
# in order to be able to attach it to the appropriate roles, as per the exported configuration.

# Billing Read-Only Policies / Roles
data "aws_iam_policy" "aws_billing_access" {
  count = local.billing_policy_enabled ? 1 : 0

  arn = "arn:${local.aws_partition}:iam::aws:policy/AWSBillingReadOnlyAccess"
}

resource "aws_iam_policy" "billing" {
  count = local.billing_policy_enabled ? 1 : 0

  name   = format("%s-billing", module.this.id)
  policy = data.aws_iam_policy.aws_billing_access[0].policy

  tags = module.introspection.tags
}

# Billing Admin Policies / Roles
data "aws_iam_policy" "aws_billing_admin_access" {
  count = local.billing_admin_policy_enabled ? 1 : 0

  arn = "arn:${local.aws_partition}:iam::aws:policy/job-function/Billing"
}

data "aws_iam_policy_document" "billing_admin_access_aggregated" {
  count = local.billing_admin_policy_enabled ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy.aws_billing_admin_access[0].policy,
    data.aws_iam_policy.aws_support_access[0].policy, # Include support access for the billing role, defined in `support-policy.tf`
  ]
}

resource "aws_iam_policy" "billing_admin" {
  count = local.billing_admin_policy_enabled ? 1 : 0

  name   = format("%s-billing-admin", module.this.id)
  policy = data.aws_iam_policy_document.billing_admin_access_aggregated[0].json

  tags = module.introspection.tags
}
